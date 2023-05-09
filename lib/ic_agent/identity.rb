require 'digest'
require 'json'
require 'ecdsa'
require 'bitcoin/trezor/mnemonic'
require 'ed25519'
require 'rbsecp256k1'
require 'ctf_party'

module IcAgent
  class Identity
    attr_reader :privkey, :pubkey, :der_pubkey, :sk, :vk, :key_type

    def initialize(privkey = '', type = 'ed25519', anonymous = false)
      privkey = [privkey].pack('H*')
      @anonymous = anonymous
      if @anonymous
        return
      end
      @key_type = type
      if type == 'secp256k1'
        data = privkey.length > 0 ? privkey : Random.new.bytes(32)
        @sk = Secp256k1::PrivateKey.from_data(data)
        @privkey = @sk.data.str2hex
        context = Secp256k1::Context.create
        @vk = context.key_pair_from_private_key(data)
        @pubkey = @vk.public_key.uncompressed.str2hex
        @der_pubkey = "#{IcAgent::IC_PUBKEY_SECP_DER_HERD}#{@pubkey}".hex2str
      elsif type == 'ed25519'
        @sk = privkey.length > 0 ? Ed25519::SigningKey.new(privkey) : Ed25519::SigningKey.generate
        @privkey = @sk.keypair.unpack1('H*')
        @vk = @sk.verify_key
        @pubkey = @vk.to_bytes.unpack1('H*')
        @der_pubkey = "#{IcAgent::IC_PUBKEY_ED_DER_HEAD}#{@vk.to_bytes.unpack1('H*')}".hex2str
      else
        raise 'unsupported identity type'
      end
    end

    def sender
      if @anonymous
        IcAgent::Principal.anonymous
      else
        IcAgent::Principal.self_authenticating(@der_pubkey)
      end
    end

    def sign(msg)
      if @anonymous
        [nil, nil]
      elsif @key_type == 'ed25519'
        sig = @sk.sign(msg)
        [@der_pubkey, sig]
      elsif @key_type == 'secp256k1'
        context = Secp256k1::Context.create
        sig = context.sign(@sk, Digest::SHA256.digest(msg)).compact
        [@der_pubkey, sig]
      end
    end

    def verify(msg, sig)
      if @anonymous
        false
      else
        @vk.verify(sig, msg)
      end
    end

    def to_pem
      OpenSSL::PKey::EC.new(@sk).to_pem
    end

    def to_s
      "(#{@key_type}, #{@privkey}, #{@pubkey})"
    end

    alias_method :inspect, :to_s
  end

  class DelegateIdentity
    attr_reader :identity, :delegations, :der_pubkey

    def initialize(identity, delegation)
      @identity = identity
      @delegations = delegation['delegations'].map { |d| d }
      @der_pubkey = [delegation['publicKey']].pack('H*')
    end

    def sign(msg)
      @identity.sign(msg)
    end

    def sender
      Principal.self_authenticating(@der_pubkey)
    end

    def self.from_json(ic_identity, ic_delegation)
      parsed_ic_identity = JSON.parse(ic_identity)
      parsed_ic_delegation = JSON.parse(ic_delegation)

      return DelegateIdentity.new(
        Identity.new(parsed_ic_identity[1][0...64]),
        parsed_ic_delegation
      )
    end

    def to_s
      "(#{@identity.to_s},\n#{@delegations.to_s})"
    end

    alias_method :inspect, :to_s
  end
end