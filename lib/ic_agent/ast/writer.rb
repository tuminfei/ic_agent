module IcAgent
  module Ast
    # The Writer class provides methods to represent an Abstract Syntax Tree (AST) in different formats.
    class Writer
      # Initializes the Writer with an Abstract Syntax Tree (AST).
      #
      # Parameters:
      # - tree: The Abstract Syntax Tree (AST) to be represented.
      def initialize(tree)
        @tree = tree
      end

      # Writes the AST in the desired format.
      #
      # Parameters:
      # - return_type: The desired format to represent the AST (:string by default).
      #
      # Returns:
      # - The AST in the specified format:
      #   - :tree: Returns the original AST.
      #   - :array: Returns the AST as an array.
      #   - :string: Returns the AST as a string.
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
