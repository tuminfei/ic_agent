require 'treetop'

module IcAgent
  module Ast
    module Nodes
      # Represents a statement node in the abstract syntax tree with additional attributes.
      class StatementNode < Treetop::Runtime::SyntaxNode
        # Additional attributes to store child count and depth.
        attr_accessor :child_count, :depth

        # The title of the statement node, by default :named_node.
        def title
          :named_node
        end

        # Converts the statement node and its children to an array representation.
        def to_array
          [title] + elements.map(&:to_array)
        end

        # Converts the statement node and its children to a string representation.
        def to_s
          "#{title.to_s.upcase} #{elements_to_s}"
        end

        # Converts the children of the statement node to a string.
        def elements_to_s
          elements.map(&:to_s).join("\n")
        end

        # Adds a child to the statement node.
        def add_child
          @child_count ||= 0 + 1
        end

        # Returns the source content of the statement node by removing leading and trailing whitespaces.
        def source_content
          self.text_value.strip
        end
      end

      # Represents an IC base type node in the abstract syntax tree, a subclass of StatementNode.
      class IcBaseType < StatementNode
        # The title of the IC base type node.
        def title
          :base_type
        end

        # Converts the IC base type node to a string representation.
        def to_s
          elements_to_s
        end
      end

      # Represents an IC base type single node in the abstract syntax tree, a subclass of StatementNode.
      class IcBaseTypeSingle < StatementNode
        # The title of the IC base type single node.
        def title
          :base_type_single
        end

        # Converts the IC base type single node to a string representation.
        def to_s
          elements_to_s
        end

        # Returns the opt code for the IC base type single node, which is 'single'.
        def opt_code
          'single'
        end
      end

      # Represents an IC base type record node in the abstract syntax tree, a subclass of StatementNode.
      class IcBaseTypeRecord < StatementNode
        # The title of the IC base type record node.
        def title
          :base_type_record
        end

        # Converts the IC base type record node to a string representation.
        def to_s
          elements_to_s
        end

        # Returns the opt code for the IC base type record node, which is 'record'.
        def opt_code
          'record'
        end
      end

      # Represents an IC base type key node in the abstract syntax tree, a subclass of StatementNode.
      class IcBaseTypeKey < StatementNode
        # The title of the IC base type key node.
        def title
          :base_type_key
        end

        # Converts the IC base type key node to a string representation.
        def to_s
          elements_to_s
        end
      end

      # Represents an IC base type value node in the abstract syntax tree, a subclass of StatementNode.
      class IcBaseTypeValue < StatementNode
        # The title of the IC base type value node.
        def title
          :base_type_value
        end

        # Converts the IC base type value node to a string representation.
        def to_s
          elements_to_s
        end
      end

      # Represents an IC type definition node in the abstract syntax tree, a subclass of StatementNode.
      class IcTypeDef < StatementNode
        # The title of the IC type definition node.
        def title
          :base_type_def
        end

        # Converts the IC type definition node to a string representation.
        def to_s
          elements_to_s
        end
      end

      # Represents an IC base type variant node in the abstract syntax tree, a subclass of StatementNode.
      class IcBaseTypeVariant < StatementNode
        # The title of the IC base type variant node.
        def title
          :base_type_variant
        end

        # Converts the IC base type variant node to a string representation.
        def to_s
          elements_to_s
        end

        # Returns the opt code for the IC base type variant node, which is 'variant'.
        def opt_code
          'variant'
        end
      end

      # Represents an IC base type function node in the abstract syntax tree, a subclass of StatementNode.
      class IcBaseTypeFunc < StatementNode
        # The title of the IC base type function node.
        def title
          :base_type_func
        end

        # Converts the IC base type function node to a string representation.
        def to_s
          elements_to_s
        end

        # Returns the opt code for the IC base type function node, which is 'func'.
        def opt_code
          'func'
        end
      end

      # Represents an IC base type optional node in the abstract syntax tree, a subclass of StatementNode.
      class IcBaseTypeOpt < StatementNode
        # The title of the IC base type optional node.
        def title
          :base_type_opt
        end

        # Converts the IC base type optional node to a string representation.
        def to_s
          elements_to_s
        end

        # Returns the opt code for the IC base type optional node, which is 'opt'.
        def opt_code
          'opt'
        end
      end

      # Represents an IC base type vector node in the abstract syntax tree, a subclass of StatementNode.
      class IcBaseTypeVec < StatementNode
        # The title of the IC base type vector node.
        def title
          :base_type_vec
        end

        # Converts the IC base type vector node to a string representation.
        def to_s
          elements_to_s
        end

        # Returns the opt code for the IC base type vector node, which is 'vec'.
        def opt_code
          'vec'
        end
      end

      # Represents an IC base type other node in the abstract syntax tree, a subclass of StatementNode.
      class IcBaseTypeOther < StatementNode
        # The title of the IC base type other node.
        def title
          :base_type_other
        end

        # Converts the IC base type other node to a string representation.
        def to_s
          elements_to_s
        end

        # Returns the opt code for the IC base type other node.
        def opt_code
          text_value
        end
      end

      # Represents the content of an IC base type node in the abstract syntax tree, a subclass of StatementNode.
      class IcBaseTypeContent < StatementNode
        # The title of the IC base type content node.
        def title
          :base_type_content
        end

        # Converts the IC base type content node to a string representation.
        def to_s
          elements_to_s
        end
      end

      # Represents a child of an IC base type node in the abstract syntax tree, a subclass of StatementNode.
      class IcBaseTypeChild < StatementNode
        # The title of the IC base type child node.
        def title
          :base_type_child
        end

        # Converts the IC base type child node to a string representation.
        def to_s
          elements_to_s
        end
      end

      # Represents an IC type name node in the abstract syntax tree, a subclass of StatementNode.
      class IcTypeName < StatementNode
        # The title of the IC type name node.
        def title
          :type_name
        end

        # Converts the IC type name node to a string representation.
        def to_s
          elements_to_s
        end
      end

      # Represents a statement block node in the abstract syntax tree, a subclass of StatementNode.
      class StatementBlock < StatementNode
        # The title of the statement block node.
        def title
          :statement_block
        end

        # Converts the statement block node to a string representation.
        def to_s
          elements_to_s
        end
      end

      # Represents the content of a statement node in the abstract syntax tree, a subclass of StatementNode.
      class StatementContent < StatementNode
        # The title of the statement content node.
        def title
          :statement_content
        end

        # Converts the statement content node to a string representation.
        def to_s
          elements_to_s
        end
      end
    end
  end
end
