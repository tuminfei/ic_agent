require 'digest/sha2'
require 'leb128'

module IcAgent
  module Utils
    def encode_list(l)
      ret = ''
      l.each do |item|
        v = item
        if item.is_a?(Array)
          v = encode_list(item)
        end
        if item.is_a?(Integer)
          v = LEB128.encode_signed(v)
        end
        if item.is_a?(String)
          v = item.bytes
        end
        ret += Digest::SHA256.digest(v)
      end
      ret
    end
    
    # used for sort record by key
    def label_hash(s)
      if s =~ /(^_\d+_$)|(^_0x[0-9a-fA-F]+_$)/
        num = s[1..-2]
        begin
          if num.start_with?("0x")
            num = num.to_i(16)
          else
            num = num.to_i
          end
        rescue
          # fallback
        end
        if num.is_a?(Integer) && num >= 0 && num < 2**32
          return num
        end
      end
      idl_hash(s)
    end
    
    def idl_hash(s)
      h = 0
      s.bytes.each do |c|
        h = (h * 223 + c) % 2**32
      end
      h
    end
    
    def to_request_id(d)
      if !d.is_a?(Hash)
        puts d
      end
      vec = []
      d.each do |k, v|
        if v.is_a?(Array)
          v = encode_list(v)
        end
        if v.is_a?(Integer)
          v = LEB128.encode_signed(v)
        end
        h_k = Digest::SHA256.digest(k)
        h_v = Digest::SHA256.digest(v)
        vec.append(h_k + h_v)
      end
      s = vec.sort.join('')
      Digest::SHA256.digest(s)
    end
  end
end
