require 'zlib'
require 'base32'

module IcAgent
  CRC_LENGTH_IN_BYTES = 4
  HASH_LENGTH_IN_BYTES = 28
  MAX_LENGTH_IN_BYTES = 29

  class PrincipalSort
    OPAQUE_ID = 1
    SELF_AUTHENTICATING = 2
    DERIVED_ID = 3
    ANONYMOUS = 4
    # Unassigned
  end

  # Base class for Principal.
  class Principal
    attr_reader :len, :bytes, :is_principal, :hex

    # Initializes a new instance of the Principal class.
    #
    # Parameters:
    # - bytes: The bytes representing the principal. Defaults to an empty string.
    def initialize(bytes: ''.b)
      @len = bytes.length
      @bytes = bytes
      @hex = @bytes.unpack1('H*').upcase
      @is_principal = true
    end

    # Creates a new Principal instance representing the management canister.
    #
    # Returns: The Principal instance representing the management canister.
    def self.management_canister
      Principal.new
    end

    # Creates a new self-authenticating Principal.
    #
    # Parameters:
    # - pubkey: The public key associated with the self-authenticating Principal.
    #
    # Returns: The self-authenticating Principal instance.
    def self.self_authenticating(pubkey)
      # check pubkey.size for is ed25519 or secp256k1
      pubkey = [pubkey].pack('H*') if pubkey.size != 44 && pubkey.size != 88

      hash_ = OpenSSL::Digest::SHA224.digest(pubkey)
      hash_ += [PrincipalSort::SELF_AUTHENTICATING].pack('C')
      Principal.new(bytes: hash_)
    end

    # Creates a new anonymous Principal.
    #
    # Returns: The anonymous Principal instance.
    def self.anonymous
      Principal.new(bytes: "\x04".b)
    end

    # Creates a new Principal from a string representation.
    #
    # Parameters:
    # - s: The string representation of the Principal.
    #
    # Returns: The Principal instance.
    def self.from_str(s)
      s1 = s.delete('-')
      pad_len = ((s1.length / 8.0).ceil * 8) - s1.length
      b = Base32.decode(s1.upcase + ('=' * pad_len))
      raise 'principal length error' if b.length < CRC_LENGTH_IN_BYTES

      p = Principal.new(bytes: b[CRC_LENGTH_IN_BYTES..-1])
      raise 'principal format error' unless p.to_str == s

      p
    end

    # Creates a new Principal from a hexadecimal string representation.
    #
    # Parameters:
    # - s: The hexadecimal string representation of the Principal.
    #
    # Returns: The Principal instance.
    def self.from_hex(s)
      Principal.new(bytes: [s].pack('H*'))
    end

    # Converts the Principal to a string representation.
    #
    # Returns: The string representation of the Principal.
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

    # Converts the Principal to an AccountIdentifier.
    #
    # Parameters:
    # - sub_account: The sub-account identifier. Defaults to 0.
    #
    # Returns: The AccountIdentifier instance.
    def to_account_id(sub_account = 0)
      AccountIdentifier.generate(self, sub_account)
    end

    def to_s
      to_str
    end

    # Compares the Principal with another Principal.
    #
    # Parameters:
    # - other: The other Principal to compare with.
    #
    # Returns: The comparison result as a string ('lt', 'eq', or 'gt').
    def compare_to(other)
      (0...[self.bytes.length, other.bytes.length].min).each do |i|
        if self.bytes[i] < other.bytes[i]
          return 'lt'
        elsif self.bytes[i] > other.bytes[i]
          return 'gt'
        end
      end

      if self.bytes.length < other.bytes.length
        'lt'
      elsif self.bytes.length > other.bytes.length
        'gt'
      else
        'eq'
      end
    end

    # Utility method checking whether a provided Principal is less than or equal to the current one using the `compare_to` method.
    #
    # Parameters:
    # - other: The other Principal to compare with.
    #
    # Returns: `true` if the current Principal is less than or equal to the provided Principal, otherwise `false`.
    def lt_eq(other)
      cmp = compare_to(other)
      %w[lt eq].include?(cmp)
    end

    # Utility method checking whether a provided Principal is greater than or equal to the current one using the `compare_to` method.
    #
    # Parameters:
    # - other: The other Principal to compare with.
    #
    # Returns: `true` if the current Principal is greater than or equal to the provided Principal, otherwise `false`.
    def gt_eq(other)
      cmp = compare_to(other)
      %w[gt eq].include?(cmp)
    end
  end

  class AccountIdentifier
    attr_reader :bytes

    # Initializes a new instance of the AccountIdentifier class.
    #
    # Parameters:
    # - hash: The hash representing the AccountIdentifier.
    def initialize(hash)
      raise 'Invalid hash length' unless hash.length == 32

      @bytes = hash
    end

    # Converts the AccountIdentifier to a string representation.
    #
    # Returns: The string representation of the AccountIdentifier.
    def to_str
      '0x' + @bytes.unpack1('H*')
    end

    def to_s
      to_str
    end

    # Generates a new AccountIdentifier from a Principal.
    #
    # Parameters:
    # - principal: The Principal associated with the AccountIdentifier.
    # - sub_account: The sub-account identifier. Defaults to 0.
    #
    # Returns: The AccountIdentifier instance.
    def self.generate(principal, sub_account = 0)
      sha224 = OpenSSL::Digest::SHA224.new
      sha224 << "\naccount-id"
      sha224 << principal.bytes
      format_sub_account = "%08d" % sub_account
      sub_account = format_sub_account.chars.map { |c| c.to_i }.pack('N*')
      sha224 << sub_account
      hash = sha224.digest
      checksum = Zlib.crc32(hash) & 0xFFFFFFFF
      account = [checksum].pack('N') + hash
      AccountIdentifier.new(account)
    end
  end
end
