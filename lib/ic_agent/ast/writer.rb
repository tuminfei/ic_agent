module IcAgent
  module Ast
    class Writer
      def initialize(tree)
        @tree = tree
      end

      def write(return_type = :string)
        if return_type == :tree
          @tree
        elsif return_type == :array
          @tree.to_array
        else
          @tree.to_s
        end
      end
    end
  end
end
