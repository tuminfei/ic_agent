require 'digest'
require 'json'
require 'ecdsa'
require 'bitcoin/trezor/mnemonic'
require 'ed25519'

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
        if privkey.length > 0
          @sk = ECDSA::Format::IntegerOctetString.decode(privkey)
        else
          @sk = ECDSA::PrivateKey.generate
        end
        @privkey = ECDSA::Format::IntegerOctetString.encode(@sk, 32).unpack1('H*')
        @vk = @sk.public_key
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
end