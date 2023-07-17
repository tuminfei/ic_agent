require 'digest'
require 'json'
require 'ecdsa'
require 'bitcoin/trezor/mnemonic'
require 'ed25519'
require 'rbsecp256k1'
require 'ctf_party'
require 'base64'

module IcAgent
  class Identity
    attr_reader :privkey, :pubkey, :der_pubkey, :sk, :vk, :key_type

    # Initializes a new instance of the Identity class.
    #
    # Parameters:
    # - privkey: The private key of the identity in hexadecimal format. Defaults to an empty string.
    # - type: The key type of the identity. Defaults to 'ed25519'.
    # - anonymous: A flag indicating whether the identity is anonymous. Defaults to false.
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
        @privkey = @sk.keypair.unpack1('H*')[0..63]
        @vk = @sk.verify_key
        @pubkey = @vk.to_bytes.unpack1('H*')
        @der_pubkey = "#{IcAgent::IC_PUBKEY_ED_DER_HEAD}#{@vk.to_bytes.unpack1('H*')}".hex2str
      else
        raise 'unsupported identity type'
      end
    end

    # Creates a new Identity instance from a seed phrase (mnemonic).
    #
    # Parameters:
    # - mnemonic: The seed phrase (mnemonic) used to generate the identity.
    #
    # Returns: The Identity instance.
    def self.from_seed(mnemonic)
      seed = Bitcoin::Trezor::Mnemonic.to_seed(mnemonic)
      privkey = seed[0..63]
      key_type = 'ed25519'
      Identity.new(privkey = privkey, type = key_type)
    end

    # Returns the sender Principal associated with the Identity.
    #
    # Returns: The sender Principal.
    def sender
      if @anonymous
        IcAgent::Principal.anonymous
      else
        IcAgent::Principal.self_authenticating(@der_pubkey)
      end
    end

    # Signs a message using the Identity.
    #
    # Parameters:
    # - msg: The message to sign.
    #
    # Returns: An array containing the DER-encoded public key and the signature.
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

    # Verifies a message signature using the Identity.
    #
    # Parameters:
    # - msg: The message to verify.
    # - sig: The signature to verify.
    #
    # Returns: `true` if the signature is valid, otherwise `false`.
    def verify(msg, sig)
      if @anonymous
        false
      else
        @vk.verify(sig, msg)
      end
    end

    # Returns the PEM-encoded private key of the Identity.
    #
    # Returns: The PEM-encoded private key.
    def to_pem
      der = @key_type == 'secp256k1' ? "#{IcAgent::IC_PUBKEY_SECP_DER_HERD}#{@sk.data.unpack1('H*')}".hex2str : "#{IcAgent::IC_PUBKEY_ED_DER_HEAD}#{@sk.to_bytes.unpack1('H*')}".hex2str
      b64 = Base64.strict_encode64(der)
      lines = ["-----BEGIN PRIVATE KEY-----\n"]
      lines.concat(b64.chars.each_slice(64).map(&:join).map { |line| "#{line}\n" })
      lines << "-----END PRIVATE KEY-----\n"
      lines.join
    end

    def to_s
      "(#{@key_type}, #{@privkey}, #{@pubkey})"
    end

    alias inspect to_s
  end

  class DelegateIdentity
    attr_reader :identity, :delegations, :der_pubkey

    # Initializes a new instance of the DelegateIdentity class.
    #
    # Parameters:
    # - identity: The Identity associated with the DelegateIdentity.
    # - delegation: The delegation JSON object containing the delegated keys.
    def initialize(identity, delegation)
      @identity = identity
      @delegations = delegation['delegations'].map { |d| d }
      @der_pubkey = [delegation['publicKey']].pack('H*')
    end

    # Signs a message using the DelegateIdentity.
    #
    # Parameters:
    # - msg: The message to sign.
    #
    # Returns: An array containing the DER-encoded public key and the signature.
    def sign(msg)
      @identity.sign(msg)
    end

    # Returns the sender Principal associated with the DelegateIdentity.
    #
    # Returns: The sender Principal.
    def sender
      Principal.self_authenticating(@der_pubkey)
    end

    # Creates a new DelegateIdentity instance from JSON representations of the Identity and delegation.
    #
    # Parameters:
    # - ic_identity: The JSON representation of the Identity.
    # - ic_delegation: The JSON representation of the delegation.
    #
    # Returns: The DelegateIdentity instance.
    def self.from_json(ic_identity, ic_delegation)
      parsed_ic_identity = JSON.parse(ic_identity)
      parsed_ic_delegation = JSON.parse(ic_delegation)

      DelegateIdentity.new(
        Identity.new(parsed_ic_identity[1][0...64]),
        parsed_ic_delegation
      )
    end

    def to_s
      "(#{@identity.to_s},\n#{@delegations.to_s})"
    end

    alias inspect to_s
  end
end
