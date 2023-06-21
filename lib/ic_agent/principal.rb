require 'zlib'
require 'base32'

module IcAgent
  CRC_LENGTH_IN_BYTES = 4
  HASH_LENGTH_IN_BYTES = 28
  MAX_LENGTH_IN_BYTES = 29

  class PrincipalSort
    OpaqueId = 1
    SelfAuthenticating = 2
    DerivedId = 3
    Anonymous = 4
    # Unassigned
  end

  class Principal
    attr_reader :len, :bytes, :is_principal, :hex

    def initialize(bytes: ''.b)
      @len = bytes.length
      @bytes = bytes
      @hex = @bytes.unpack1('H*').upcase
      @is_principal = true
    end

    def self.management_canister
      Principal.new
    end

    def self.self_authenticating(pubkey)
      # check pubkey.size for is ed25519 or secp256k1
      pubkey = [pubkey].pack('H*') if pubkey.size != 44 && pubkey.size != 88

      hash_ = OpenSSL::Digest::SHA224.digest(pubkey)
      hash_ += [PrincipalSort::SelfAuthenticating].pack('C')
      Principal.new(bytes: hash_)
    end

    def self.anonymous
      Principal.new(bytes: "\x04".b)
    end

    def self.from_str(s)
      s1 = s.delete('-')
      pad_len = ((s1.length / 8.0).ceil * 8) - s1.length
      b = Base32.decode(s1.upcase + ('=' * pad_len))
      raise 'principal length error' if b.length < CRC_LENGTH_IN_BYTES

      p = Principal.new(bytes: b[CRC_LENGTH_IN_BYTES..-1])
      raise 'principal format error' unless p.to_str == s

      p
    end

    def self.from_hex(s)
      Principal.new(bytes: [s].pack('H*'))
    end

    def to_str
      checksum = Zlib.crc32(@bytes) & 0xFFFFFFFF
      b = ''
      b += [checksum].pack('N')
      b += @bytes
      s = Base32.encode(b).downcase.delete('=')
      ret = ''
      while s.length > 5
        ret += s[0..4] + '-'
        s = s[5..-1]
      end
      ret + s
    end

    def to_account_id(sub_account = 0)
      AccountIdentifier.generate(self, sub_account)
    end

    def to_s
      to_str
    end
  end

  class AccountIdentifier
    attr_reader :bytes

    def initialize(hash)
      raise 'Invalid hash length' unless hash.length == 32

      @bytes = hash
    end

    def to_str
      '0x' + @bytes.unpack1('H*')
    end

    def to_s
      to_str
    end

    def self.generate(principal, sub_account = 0)
      sha224 = OpenSSL::Digest::SHA224.new
      sha224 << "\naccount-id"
      sha224 << principal.bytes
      format_sub_account = "%08d" % sub_account
      sub_account = format_sub_account.chars.map {|c| c.to_i}.pack('N*')
      sha224 << sub_account
      hash = sha224.digest
      checksum = Zlib.crc32(hash) & 0xFFFFFFFF
      account = [checksum].pack('N') + hash
      AccountIdentifier.new(account)
    end
  end
end
