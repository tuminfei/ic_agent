require 'treetop'

module IcAgent
  module Ast
    module Nodes
      class StringLiteral < Treetop::Runtime::SyntaxNode
        def to_array
          self.text_value
        end

        def to_s
          self.text_value
        end
      end
    end
  end
end
