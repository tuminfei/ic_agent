require 'treetop'

module IcAgent
  module Ast
    module Nodes
      # Represents a named node in the abstract syntax tree.
      class NamedNode < Treetop::Runtime::SyntaxNode
        # The title of the named node.
        def title
          :named_node
        end

        # Converts the node and its children to an array representation.
        def to_array
          [title] + elements.map(&:to_array)
        end

        # Converts the node and its children to a string representation.
        def to_s
          "#{title.to_s.upcase} #{elements_to_s}"
        end

        def elements_to_s
          elements.map(&:to_s).join("\n")
        end

        def source_content
          self.text_value.strip
        end
      end

      # Represents an instruction node in the abstract syntax tree, a subclass of NamedNode.
      class Instruction < NamedNode
        # The title of the instruction node.
        def title
          :instruction
        end

        # Converts the instruction node to a string representation.
        def to_s
          elements_to_s
        end
      end

      # Represents a comment node in the abstract syntax tree, a subclass of NamedNode.
      class Comment < NamedNode
        # The title of the comment node.
        def title
          :comment
        end

        # Converts the comment node to a string representation with '#' prefix.
        def to_s
          "# #{elements[0].to_s}"
        end
      end

      # Represents a DID file node in the abstract syntax tree, a subclass of NamedNode.
      class DIDFile < NamedNode
        # The title of the DID file node.
        def title
          :did_file
        end

        # Converts the DID file node to a string representation.
        def to_s
          elements_to_s
        end
      end

      # Represents a type declaration node in the abstract syntax tree, a subclass of NamedNode.
      class TypeDeclaration < NamedNode
        # The title of the type declaration node.
        def title
          :type_declaration
        end

        # Returns the name of the type parameter.
        def type_param_name
          elements[0].source_content
        end

        # Returns the content of the type parameter without newlines and trailing ';}' replaced with '}'.
        def type_param_content
          elements[1].source_content.gsub("\n", '').gsub(';}', '}')
        end

        # Returns the opt code of the root type element.
        def type_root_opt_code
          elements[1].opt_code
        end

        # Returns an array of type child items.
        def type_child_items
          if elements && elements[1] && elements[1].elements && elements[1].elements[0]
            elements[1].elements[0].elements
          else
            []
          end
        end

        # Returns an array of keys of type child items.
        def type_child_item_keys
          names = []
          type_child_items.each do |ele|
            names << ele.elements[0].text_value.strip
          end
          names
        end

        # Returns an array of referenced types in the type parameter content.
        def type_refer_items
          source_string = self.type_param_content
          parser = IcAgent::Ast::StatementParser.new
          parser.parse(source_string)
          refer_type = parser.source_tree.content[:refer_type]
          refer_type
        end

        # Converts the type declaration node to a string representation.
        def to_s
          text_value
        end

        # Converts the type declaration node to a hash representation.
        def to_obj
          {
            'type_param_name' => type_param_name,
            'type_root_opt_code' => type_root_opt_code,
            'type_child_item_keys' => type_child_item_keys,
            'type_child_item_values' => type_refer_items
          }
        end
      end

      # Represents a base type node in the abstract syntax tree, a subclass of NamedNode.
      class BaseType < NamedNode
        # The title of the base type node.
        def title
          :base_type
        end

        # Converts the base type node to a string representation.
        def to_s
          elements_to_s
        end
      end

      # Represents a single base type node in the abstract syntax tree, a subclass of BaseType.
      class BaseTypeSingle < NamedNode
        # The title of the single base type node.
        def title
          :base_type_single
        end

        # Converts the single base type node to a string representation.
        def to_s
          elements_to_s
        end

        # Returns the opt code for the single base type.
        def opt_code
          'single'
        end
      end

      # Represents a record base type node in the abstract syntax tree, a subclass of BaseType.
      class BaseTypeRecord < NamedNode
        # The title of the record base type node.
        def title
          :base_type_record
        end

        # Converts the record base type node to a string representation.
        def to_s
          elements_to_s
        end

        # Returns the opt code for the record base type.
        def opt_code
          'record'
        end
      end

      # Represents a key base type node in the abstract syntax tree, a subclass of BaseType.
      class BaseTypeKey < NamedNode
        # The title of the key base type node.
        def title
          :base_type_key
        end

        # Converts the key base type node to a string representation.
        def to_s
          elements_to_s
        end
      end

      # Represents a variant base type node in the abstract syntax tree, a subclass of BaseType.
      class BaseTypeVariant < NamedNode
        # The title of the variant base type node.
        def title
          :base_type_variant
        end

        # Converts the variant base type node to a string representation.
        def to_s
          elements_to_s
        end

        # Returns the opt code for the variant base type.
        def opt_code
          'variant'
        end
      end

      # Represents a function base type node in the abstract syntax tree, a subclass of BaseType.
      class BaseTypeFunc < NamedNode
        # The title of the function base type node.
        def title
          :base_type_func
        end

        # Converts the function base type node to a string representation.
        def to_s
          elements_to_s
        end

        # Returns the opt code for the function base type.
        def opt_code
          'func'
        end
      end

      # Represents an optional base type node in the abstract syntax tree, a subclass of BaseType.
      class BaseTypeOpt < NamedNode
        # The title of the optional base type node.
        def title
          :base_type_opt
        end

        # Converts the optional base type node to a string representation.
        def to_s
          elements_to_s
        end

        # Returns the opt code for the optional base type.
        def opt_code
          'opt'
        end
      end

      # Represents a vector base type node in the abstract syntax tree, a subclass of BaseType.
      class BaseTypeVec < NamedNode
        # The title of the vector base type node.
        def title
          :base_type_vec
        end

        # Converts the vector base type node to a string representation.
        def to_s
          elements_to_s
        end

        # Returns the opt code for the vector base type.
        def opt_code
          'vec'
        end
      end

      # Represents an other base type node in the abstract syntax tree, a subclass of BaseType.
      class BaseTypeOther < NamedNode
        # The title of the other base type node.
        def title
          :base_type_other
        end

        # Converts the other base type node to a string representation.
        def to_s
          elements_to_s
        end

        # Returns the opt code for the other base type.
        def opt_code
          text_value
        end
      end

      # Represents the content of a base type node in the abstract syntax tree, a subclass of NamedNode.
      class BaseTypeContent < NamedNode
        # The title of the base type content node.
        def title
          :base_type_content
        end

        # Converts the base type content node to a string representation.
        def to_s
          elements_to_s
        end
      end

      # Represents a child of a base type node in the abstract syntax tree, a subclass of NamedNode.
      class BaseTypeChild < NamedNode
        # The title of the base type child node.
        def title
          :base_type_child
        end

        # Converts the base type child node to a string representation.
        def to_s
          elements_to_s
        end
      end

      # Represents a type name node in the abstract syntax tree, a subclass of NamedNode.
      class TypeName < NamedNode
        # The title of the type name node.
        def title
          :type_name
        end

        # Converts the type name node to a string representation.
        def to_s
          elements_to_s
        end
      end

      # Represents an IC service node in the abstract syntax tree, a subclass of NamedNode.
      class Service < NamedNode
        # The title of the IC service node.
        def title
          :ic_service
        end

        # Converts the IC service node to a string representation.
        def to_s
          elements_to_s
        end
      end

      # Represents an IC service name node in the abstract syntax tree, a subclass of NamedNode.
      class IcServiceName < NamedNode
        # The title of the IC service name node.
        def title
          :ic_service_name
        end

        # Converts the IC service name node to a string representation with '#' prefix.
        def to_s
          "# #{elements[0].to_s}"
        end
      end

      # Represents IC service methods node in the abstract syntax tree, a subclass of NamedNode.
      class IcServiceMethods < NamedNode
        # The title of the IC service methods node.
        def title
          :ic_service_methods
        end

        # Returns an array of IC service method nodes.
        def value
          elements.map { |update| update.value }
        end
      end

      # Represents an IC service method name node in the abstract syntax tree, a subclass of NamedNode.
      class IcServiceMethodName < NamedNode
        # The title of the IC service method name node.
        def title
          :ic_service_method_name
        end
      end

      # Represents an IC service item node in the abstract syntax tree, a subclass of NamedNode.
      class IcServiceItem < NamedNode
        # The title of the IC service item node.
        def title
          :ic_service_item
        end

        # Converts the IC service item node to a string representation.
        def to_s
          elements_to_s
        end

        # Converts the IC service item node to a hash representation.
        def to_obj
          obj = {}
          elements.each do |element|
            obj[element.title.to_s] = element.text_value.gsub("\n", '')
          end
          obj
        end
      end

      # Represents an IC service param node in the abstract syntax tree, a subclass of NamedNode.
      class IcServiceParam < NamedNode
        # The title of the IC service param node.
        def title
          :ic_service_param
        end

        # Converts the IC service param node to a string representation with '#' prefix.
        def to_s
          "# #{elements[0].to_s}"
        end
      end

      # Represents an IC service name node in the abstract syntax tree, a subclass of NamedNode.
      class IcServiceName < NamedNode
        # The title of the IC service name node.
        def title
          :ic_service_name
        end

        # Converts the IC service name node to a string representation with '#' prefix.
        def to_s
          "# #{elements[0].to_s}"
        end
      end

      # Represents an IC service method params node in the abstract syntax tree, a subclass of NamedNode.
      class IcServiceMethodParams < NamedNode
        # The title of the IC service method params node.
        def title
          :ic_service_method_params
        end

        # Converts the IC service method params node to a string representation.
        def to_s
          elements_to_s
        end
      end

      # Represents an IC service method return node in the abstract syntax tree, a subclass of NamedNode.
      class IcServiceMethodReturn < NamedNode
        # The title of the IC service method return node.
        def title
          :ic_service_method_return
        end

        # Converts the IC service method return node to a string representation.
        def to_s
          elements_to_s
        end
      end

      # Represents an IC service method query node in the abstract syntax tree, a subclass of NamedNode.
      class IcServiceMethodQuery < NamedNode
        # The title of the IC service method query node.
        def title
          :ic_service_method_query
        end

        # Converts the IC service method query node to a string representation.
        def to_s
          elements_to_s
        end
      end

      # Represents the content of a base type node in the abstract syntax tree, a subclass of NamedNode.
      class BaseTypeContent < NamedNode
        # The title of the IC service method query node.
        def title
          :ic_service_method_query
        end

        # Converts the IC service method query node to a string representation.
        def to_s
          elements_to_s
        end
      end
    end
  end
end
