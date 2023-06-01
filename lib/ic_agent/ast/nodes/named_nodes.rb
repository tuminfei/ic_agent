require 'treetop'

module IcAgent
  module Ast
    module Nodes
      class NamedNode < Treetop::Runtime::SyntaxNode
        def title
          :named_node
        end

        def to_array
          [title] + elements.map(&:to_array)
        end

        def to_s
          "#{title.to_s.upcase} #{elements_to_s}"
        end

        def elements_to_s
          elements.map(&:to_s).join("\n")
        end
      end

      class Instruction < NamedNode
        def title
          :instruction
        end

        def to_s
          elements_to_s
        end
      end

      class Comment < NamedNode
        def title
          :comment
        end

        def to_s
          "# #{elements[0].to_s}"
        end
      end

      class DIDFile < NamedNode
        def title
          :did_file
        end

        def to_s
          elements_to_s
        end
      end

      class TypeDeclaration < NamedNode
        def title
          :type_declaration
        end

        def type_param_name
          elements[0].text_value
        end

        def type_param_content
          elements[1].text_value
        end

        def type_root_opt_code
          elements[1].opt_code
        end

        def type_child_items
          elements[1].elements[0].elements
        end

        def type_child_item_keys
          names = []
          type_child_items.each do |ele|
            names << ele.elements[0].text_value.strip
          end
          names
        end

        def type_child_item_values
          values = []
          type_child_items.each do |ele|
            item_arr = ele.text_value.strip.split(':')
            item_value_arr = item_arr[1].strip.split(' ').collect { |v| v.strip.gsub(';', '') }
            values << (item_arr.size > 1 ? item_value_arr : [])
          end
          values
        end

        def to_s
          text_value
        end

        def to_obj
          {
            'type_param_name' => type_param_name,
            'type_root_opt_code' => type_root_opt_code,
            'type_child_item_keys' => type_child_item_keys,
            'type_child_item_values' => type_child_item_values
          }
        end
      end

      class BaseType < NamedNode
        def title
          :base_type
        end

        def to_s
          elements_to_s
        end
      end

      class BaseTypeRecord < NamedNode
        def title
          :base_type_record
        end

        def to_s
          elements_to_s
        end

        def opt_code
          'record'
        end
      end

      class BaseTypeKey < NamedNode
        def title
          :base_type_key
        end

        def to_s
          elements_to_s
        end
      end

      class BaseTypeVariant < NamedNode
        def title
          :base_type_variant
        end

        def to_s
          elements_to_s
        end

        def opt_code
          'variant'
        end
      end

      class BaseTypeOpt < NamedNode
        def title
          :base_type_opt
        end

        def to_s
          elements_to_s
        end

        def opt_code
          'opt'
        end
      end

      class BaseTypeVec < NamedNode
        def title
          :base_type_vec
        end

        def to_s
          elements_to_s
        end

        def opt_code
          'vec'
        end
      end

      class BaseTypeOther < NamedNode
        def title
          :base_type_other
        end

        def to_s
          elements_to_s
        end

        def opt_code
          text_value
        end
      end

      class BaseTypeContent < NamedNode
        def title
          :base_type_content
        end

        def to_s
          elements_to_s
        end
      end

      class BaseTypeChild < NamedNode
        def title
          :base_type_child
        end

        def to_s
          elements_to_s
        end
      end

      class TypeName < NamedNode
        def title
          :type_name
        end

        def to_s
          elements_to_s
        end
      end

      class Service < NamedNode
        def title
          :ic_service
        end

        def to_s
          elements_to_s
        end
      end

      class IcServiceName < NamedNode
        def title
          :ic_service_name
        end

        def to_s
          "# #{elements[0].to_s}"
        end
      end

      class IcServiceMethods < NamedNode
        def title
          :ic_service_methods
        end

        def value
          elements.map { |update| update.value }
        end
      end

      class IcServiceMethodName < NamedNode
        def title
          :ic_service_method_name
        end
      end

      class IcServiceItem < NamedNode
        def title
          :ic_service_item
        end

        def to_s
          elements_to_s
        end

        def to_obj
          obj = {}
          elements.each do |element|
            obj[element.title.to_s] = element.text_value
          end
          obj
        end
      end

      class IcServiceParam < NamedNode
        def title
          :ic_service_param
        end

        def to_s
          "# #{elements[0].to_s}"
        end
      end

      class IcServiceName < NamedNode
        def title
          :ic_service_name
        end

        def to_s
          "# #{elements[0].to_s}"
        end
      end

      class IcServiceMethodParams < NamedNode
        def title
          :ic_service_method_params
        end

        def to_s
          elements_to_s
        end
      end

      class IcServiceMethodReturn < NamedNode
        def title
          :ic_service_method_return
        end

        def to_s
          elements_to_s
        end
      end

      class IcServiceMethodQuery < NamedNode
        def title
          :ic_service_method_query
        end

        def to_s
          elements_to_s
        end
      end
    end
  end
end

