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

  # Base class for Principal.
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


    # self_authenticating
    # @param [Object] pubkey
    # @return [IcAgent::Principal]
    def self.self_authenticating(pubkey)
      # check pubkey.size for is ed25519 or secp256k1
      pubkey = [pubkey].pack('H*') if pubkey.size != 44 && pubkey.size != 88

      hash_ = OpenSSL::Digest::SHA224.digest(pubkey)
      hash_ += [PrincipalSort::SelfAuthenticating].pack('C')
      Principal.new(bytes: hash_)
    end

    # @return anonymous [IcAgent::Principal]
    def self.anonymous
      Principal.new(bytes: "\x04".b)
    end


    # @param s, example: i3o4q-ljrhf-s4evb-ux72j-qdb6g-wzq66-73nfa-h2k3x-dw7zj-4cxkd-zae
    # @return [IcAgent::Principal]
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

    # @return [String] example: i3o4q-ljrhf-s4evb-ux72j-qdb6g-wzq66-73nfa-h2k3x-dw7zj-4cxkd-zae
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

    # @param [Integer] sub_account
    # @return [IcAgent::AccountIdentifier] account_id
    def to_account_id(sub_account = 0)
      AccountIdentifier.generate(self, sub_account)
    end

    def to_s
      to_str
    end

    # @param [Object] other
    # @return compare results
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

    # Utility method checking whether a provided Principal is less than or equal to the current one using the `compareTo` method
    def lt_eq(other)
      cmp = compare_to(other)
      %w[lt eq].include?(cmp)
    end

    # Utility method checking whether a provided Principal is greater than or equal to the current one using the `compareTo` method
    def gt_eq(other)
      cmp = compare_to(other)
      %w[gt eq].include?(cmp)
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
