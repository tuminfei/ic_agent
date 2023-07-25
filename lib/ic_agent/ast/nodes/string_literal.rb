require 'treetop'

module IcAgent
  module Ast
    module Nodes
      # Represents a string literal node in the abstract syntax tree.
      class StringLiteral < Treetop::Runtime::SyntaxNode
        # Converts the string literal node to an array representation.
        # In this case, the array contains the text value of the string literal.
        def to_array
          self.text_value
        end

        # Converts the string literal node to a string representation.
        # In this case, it returns the text value of the string literal.
        def to_s
          self.text_value
        end
      end
    end
  end
end
