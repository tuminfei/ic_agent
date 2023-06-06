require 'ic_agent/candid'

module IcAgent
  module Ast
    class Assembler
      TYPE_MAPPING = {}

      def self.build_single_type(child_type)
        IcAgent::Candid::BaseTypes.send(child_type)
      end

      def self.build_opt(child_type, key_types = {})
        child_type = key_types[child_type].nil? ? build_type(child_type) : key_types[child_type]
        IcAgent::Candid::BaseTypes.opt(child_type)
      end

      def self.build_vec(child_type, key_types = {})
        child_type = key_types[child_type].nil? ? build_single_type(child_type) : key_types[child_type]
        IcAgent::Candid::BaseTypes.vec(child_type)
      end

      def self.build_record(child_hash, key_types = {})
        child_types = {}
        child_hash.each_key do |key|
          child_types[key] = key_types[child_hash[key].strip].nil? ? build_type(child_hash[key], key_types) : key_types[key]
        end
        IcAgent::Candid::BaseTypes.record(child_types)
      end

      def self.build_variant(child_hash, key_types = {})
        child_types = {}
        child_hash.each_key do |key|
          child_types[key] = key_types[child_hash[key].strip].nil? ? build_type(child_hash[key], key_types) : key_types[key]
        end
        IcAgent::Candid::BaseTypes.variant(child_types)
      end

      def self.build_type(type_str, key_types = {})
        byebug if key_types.keys.size > 0
        opt_code = get_opt_code(type_str)

        if IcAgent::Candid::SINGLE_TYPES.include? opt_code
          build_single_type(opt_code)
        elsif opt_code == 'opt'
          child_code = get_child_code(type_str, ' ')
          build_opt(child_code, key_types)
        elsif opt_code == 'vec'
          child_code = get_child_code(type_str, ' ')
          build_vec(child_code, key_types)
        elsif opt_code == 'record'
          child_code = get_record_content(type_str)
          child_hash = {}
          child_code.split(';').each do |item|
            byebug if item == " Followees }"
            item_key, item_value = get_record_key_value(item, ' : ')
            child_hash[item_key] = item_value
          end
          build_record(child_hash, key_types)
        elsif opt_code == 'variant'
          child_code = get_variant_content(type_str)
          child_hash = {}
          child_code.split(';').each do |item|
            item_arr = item.strip.split(' : ')
            child_hash[item_arr[0]] = (item_arr.size > 1 ? item_arr[1] : 'null')
          end
          build_variant(child_hash, key_types)
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

      def self.get_variant_content(variant_str)
        variant_str = variant_str.sub('variant', '').sub('{', '')
        variant_str = replace_last_occurrence(variant_str, '}', '')
        variant_str.strip
      end

      def self.get_record_key_value(item_str, index_str)
        first_index = item_str.index(index_str)
        byebug if first_index.nil?
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
