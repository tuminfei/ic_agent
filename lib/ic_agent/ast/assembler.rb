require 'ic_agent/candid'

module IcAgent
  module Ast
    class Assembler
      TYPE_MAPPING = {}

      # Builds a single Candid type from a given child type.
      def self.build_single_type(child_type)
        IcAgent::Candid::BaseTypes.send(child_type)
      end


      # Builds a Candid blob type.
      def self.build_blob
        IcAgent::Candid::BaseTypes.vec(IcAgent::Candid::BaseTypes.nat8)
      end

      # Builds a Candid optional type from a given child type.
      def self.build_opt(child_type, key_types = {})
        child_type = key_types[child_type].nil? ? build_type(child_type, key_types) : key_types[child_type]
        IcAgent::Candid::BaseTypes.opt(child_type)
      end

      # Builds a Candid vector type from a given child type.
      def self.build_vec(child_type, key_types = {})
        child_type = key_types[child_type].nil? ? build_type(child_type, key_types) : key_types[child_type]
        IcAgent::Candid::BaseTypes.vec(child_type)
      end

      # Builds a Candid record type from a given hash of field names and types.
      def self.build_record(child_hash, multi_types = {}, key_types = {})
        child_types = {}
        child_hash.each_key do |key|
          if multi_types[child_hash[key].strip]
            multi_type = build_type(multi_types[child_hash[key].strip], key_types, multi_types)
            child_types[key] = multi_type
          elsif key_types[child_hash[key].strip]
            child_types[key] = key_types[child_hash[key].strip]
          else
            child_types[key] = build_type(child_hash[key], key_types, multi_types)
          end
        end
        IcAgent::Candid::BaseTypes.record(child_types)
      end

      # Builds a Candid variant type from a given hash of field names and types.
      def self.build_variant(child_hash, multi_types = {}, key_types = {})
        child_types = {}
        child_hash.each_key do |key|
          if multi_types[child_hash[key].strip]
            multi_type = build_type(multi_types[child_hash[key].strip], multi_types)
            child_types[key] = multi_type
          elsif key_types[child_hash[key].strip]
            child_types[key] = key_types[child_hash[key].strip]
          else
            child_types[key] = build_type(child_hash[key], key_types, multi_types)
          end
        end
        IcAgent::Candid::BaseTypes.variant(child_types)
      end

      # Builds a Candid type based on the given type string.
      def self.build_type(type_str, key_types = {}, multi_types = {})
        opt_code = get_opt_code(type_str)

        if IcAgent::Candid::SINGLE_TYPES.include? opt_code
          build_single_type(opt_code)
        elsif opt_code == 'blob'
          build_blob
        elsif opt_code == 'opt'
          type_str = recover_type(type_str, multi_types)
          child_code = get_child_code(type_str, ' ')
          build_opt(child_code, key_types)
        elsif opt_code == 'vec'
          type_str = recover_type(type_str, multi_types)
          child_code = get_child_code(type_str, ' ')
          build_vec(child_code, key_types)
        elsif opt_code == 'record'
          child_code = get_record_content(type_str)
          pure_child_code, multi_types = replace_multi_type(child_code)
          child_hash = {}
          key_index = 0
          pure_child_code.split(';').each do |item|
            item_key, item_value = get_record_key_value(item, ' : ', key_index)
            child_hash[item_key] = item_value
            key_index += 1
          end
          build_record(child_hash, multi_types, key_types)
        elsif opt_code == 'variant'
          child_code = get_variant_content(type_str)
          pure_child_code, multi_types = replace_multi_type(child_code)
          child_hash = {}
          pure_child_code.split(';').each do |item|
            item_arr = item.strip.split(' : ')
            child_hash[item_arr[0]] = (item_arr.size > 1 ? item_arr[1] : 'null')
          end
          build_variant(child_hash, multi_types, key_types)
        end
      end

      # Replaces the last occurrence of a pattern in a string with the given replacement.
      def self.replace_last_occurrence(string, pattern, replacement)
        last_index = string.rindex(pattern)
        return string unless last_index

        string[last_index..-1] = replacement
        string
      end

      # Extracts the content of a Candid record type from the type string.
      def self.get_record_content(record_str)
        record_str = record_str.sub('record', '').sub('{', '')
        record_str = replace_last_occurrence(record_str, '}', '')
        record_str.strip
      end

      # Extracts the content of a Candid variant type from the type string.
      def self.get_variant_content(variant_str)
        variant_str = variant_str.sub('variant', '').sub('{', '')
        variant_str = replace_last_occurrence(variant_str, '}', '')
        variant_str.strip
      end

      # Extracts the key-value pairs from a Candid record item string.
      def self.get_record_key_value(item_str, index_str, key_index = 0)
        first_index = item_str.index(index_str)
        if first_index
          key = item_str[0..first_index].strip
          value = item_str[(first_index + index_str.size)..].strip
        else
          key = key_index.to_s
          value = item_str.strip
        end
        return key, value
      end

      # Extracts the Candid code (e.g., "record", "variant", "opt", etc.) from the type string.
      def self.get_opt_code(item_str)
        opt_code = item_str.strip
        opt_code.split(' ')[0]
      end

      # Extracts the child Candid code from the type string.
      def self.get_child_code(item_str, index_str)
        first_index = item_str.index(index_str)
        item_str[(first_index + index_str.size)..].strip
      end

      # Replaces occurrences of Candid record and variant types with unique type names.
      def self.replace_multi_type(type_str)
        replaced_hash = {}
        modified_str = type_str.gsub(/record\s*{[^{}]*}/) do |match|
          rad_id = rand(100000..999999)
          type_name = "record_#{rad_id}"
          replaced_hash[type_name] = match
          type_name
        end

        modified_str = modified_str.gsub(/variant\s*{[^{}]*}/) do |match|
          rad_id = rand(100000..999999)
          type_name = "variant_#{rad_id}"
          replaced_hash[type_name] = match
          type_name
        end

        return modified_str, replaced_hash
      end

      # Gets the refer types used in the type string.
      def self.get_params_refer_values(type_str)
        parser = IcAgent::Ast::StatementParser.new
        parser.parse(type_str)
        refer_type = parser.source_tree.content[:refer_type]
        refer_type
      end

      # Recovers the original type string from the multi_types hash.
      def self.recover_type(type_str, multi_types)
        multi_types.each_key do |key|
          type_str = type_str.gsub(key, multi_types[key])
        end
        type_str
      end
    end
  end
end
