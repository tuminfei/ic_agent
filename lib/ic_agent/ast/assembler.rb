require 'ic_agent/candid'

module IcAgent
  module Ast
    class Assembler
      TYPE_MAPPING = {}

      def self.build_single_type(child_type)
        IcAgent::Candid::BaseTypes.send(child_type)
      end

      def self.build_opt(child_type)
        child_type = build_type(child_type)
        IcAgent::Candid::BaseTypes.opt(child_type)
      end

      def self.build_vec(child_type)
        child_type = build_single_type(child_type)
        IcAgent::Candid::BaseTypes.vec(child_type)
      end

      def self.build_record(child_hash)
        child_types = {}
        child_hash.each_key do |key|
          child_types[key] = build_type(child_hash[key])
        end
        IcAgent::Candid::BaseTypes.record(child_types)
      end

      def self.build_variant(child_hash)
        child_types = {}
        child_hash.each_key do |key|
          child_types[key] = build_type(child_hash[key])
        end
        IcAgent::Candid::BaseTypes.variant(child_types)
      end

      def self.build_type(type_str)
        opt_code = get_opt_code(type_str)

        if IcAgent::Candid::SINGLE_TYPES.include? opt_code
          build_single_type(opt_code)
        elsif opt_code == 'opt'
          child_code = get_child_code(type_str, ' ')
          build_opt(child_code)
        elsif opt_code == 'vec'
          child_code = get_child_code(type_str, ' ')
          build_vec(child_code)
        elsif opt_code == 'record'
          child_code = get_record_content(type_str)
          child_hash = {}
          child_code.split(';').each do |item|
            item_key, item_value = get_record_key_value(item, ' : ')
            child_hash[item_key] = item_value
          end
          build_record(child_hash)
        elsif opt_code == 'variant'
          child_code = type_str.sub('record', '').gsub('{', '').gsub('}', '').strip
          child_hash = {}
          child_code.split(';').each do |item|
            item_arr = item.strip.split(' : ')
            child_hash[item_arr[0]] = item_arr[1]
          end
          build_variant(child_hash)
        end
      end

      def self.replace_last_occurrence(string, pattern, replacement)
        last_index = string.rindex(pattern)
        return string unless last_index

        string[last_index..-1] = replacement
        string
      end

      def self.get_record_content(record_str)
        record_str = record_str.sub('record', '').sub('{', '')
        record_str = replace_last_occurrence(record_str, '}', '')
        record_str.strip
      end

      def self.get_record_key_value(item_str, index_str)
        first_index = item_str.index(index_str)
        key = item_str[0..first_index].strip
        value = item_str[(first_index + index_str.size)..].strip
        return key, value
      end

      def self.get_opt_code(item_str)
        opt_code = item_str.strip
        opt_code.split(' ')[0]
      end

      def self.get_child_code(item_str, index_str)
        first_index = item_str.index(index_str)
        item_str[(first_index + index_str.size)..].strip
      end
    end
  end
end
