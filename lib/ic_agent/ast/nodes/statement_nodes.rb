require 'treetop'

module IcAgent
  module Ast
    module Nodes
      class StatementNode < Treetop::Runtime::SyntaxNode
        attr_accessor :child_count, :depth

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

        def add_child
          @child_count ||= 0 + 1
        end

        def source_content
          self.text_value.strip
        end
      end

      class IcBaseType < StatementNode
        def title
          :base_type
        end

        def to_s
          elements_to_s
        end
      end

      class IcBaseTypeSingle < StatementNode
        def title
          :base_type_single
        end

        def to_s
          elements_to_s
        end

        def opt_code
          'single'
        end
      end

      class IcBaseTypeRecord < StatementNode
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

      class IcBaseTypeKey < StatementNode
        def title
          :base_type_key
        end

        def to_s
          elements_to_s
        end
      end

      class IcBaseTypeValue < StatementNode
        def title
          :base_type_value
        end

        def to_s
          elements_to_s
        end
      end

      class IcTypeDef < StatementNode
        def title
          :base_type_def
        end

        def to_s
          elements_to_s
        end
      end

      class IcBaseTypeVariant < StatementNode
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

      class IcBaseTypeFunc < StatementNode
        def title
          :base_type_func
        end

        def to_s
          elements_to_s
        end

        def opt_code
          'func'
        end
      end

      class IcBaseTypeOpt < StatementNode
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

      class IcBaseTypeVec < StatementNode
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

      class IcBaseTypeOther < StatementNode
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

      class IcBaseTypeContent < StatementNode
        def title
          :base_type_content
        end

        def to_s
          elements_to_s
        end
      end

      class IcBaseTypeChild < StatementNode
        def title
          :base_type_child
        end

        def to_s
          elements_to_s
        end
      end

      class IcTypeName < StatementNode
        def title
          :type_name
        end

        def to_s
          elements_to_s
        end
      end

      class StatementBlock < StatementNode
        def title
          :statement_block
        end

        def to_s
          elements_to_s
        end
      end

      class StatementContent < StatementNode
        def title
          :statement_content
        end

        def to_s
          elements_to_s
        end
      end
    end
  end
end

