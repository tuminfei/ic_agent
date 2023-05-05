require 'digest'
require 'json'
require 'ecdsa'
require 'bitcoin/trezor/mnemonic'
require 'ed25519'
require 'securerandom'

module IcAgent
  class Identity
    attr_reader :privkey, :pubkey, :der_pubkey, :sk, :vk

    def initialize(privkey= '', type= 'ed25519', anonymous= false)
      privkey = [privkey].pack('H*')
      @anonymous = anonymous
      if @anonymous
        return
      end
      @key_type = type
      if type == 'secp256k1'
        group = ECDSA::Group::Secp256k1
        if privkey.length > 0
          @sk = privkey.to_i
        else
          @sk = 1 + SecureRandom.random_number(group.order - 1)
        end
        @privkey = ECDSA::Format::IntegerOctetString.encode(@sk, 32).unpack1('H*')
        @vk = group.generator.multiply_by_scalar(@sk)
        @pubkey = ECDSA::Format::PointOctetString.encode(@vk, compression: true).unpack1('H*')
        @der_pubkey = ECDSA::Format::PointOctetString.encode(@vk, compression: false)
      elsif type == 'ed25519'
        if privkey.length > 0
          @sk = Ed25519::SigningKey.new(privkey)
        else
          @sk = Ed25519::SigningKey.generate
        end
        @privkey = @sk.keypair.unpack1('H*')
        @vk = @sk.verify_key
        @pubkey = @vk.to_bytes.unpack1('H*')
        @der_pubkey = @vk.to_bytes
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
        sig = @sk.sign(msg, digest: Digest::SHA256)
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
      '(' + @key_type + ', ' + @privkey + ', ' + @pubkey + ')'
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
      return @identity.sign(msg)
    end

    def sender
      return Principal.self_authenticating(@der_pubkey)
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
      return '(' + @identity.to_s + ",\n" + @delegations.to_s + ")"
    end

    alias_method :inspect, :to_s
  end
end