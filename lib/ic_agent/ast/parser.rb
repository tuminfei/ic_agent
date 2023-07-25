require 'treetop'

module IcAgent
  module Ast
    # The Parser class provides methods to parse data using a Treetop grammar and work with the resulting Abstract Syntax Tree (AST).
    class Parser
      attr_accessor :parser, :tree

      # Initializes the Parser by loading the Treetop grammar file.
      def initialize
        Treetop.load(File.expand_path(File.join(File.dirname(__FILE__), 'did_grammar.treetop')))
        @parser = DIDGrammarParser.new
      end

      # Parses the given data using the Treetop parser and returns the AST.
      #
      # Parameters:
      # - data: The data to be parsed.
      # - return_type: The desired return type for the parse result (:string by default).
      #
      # Returns:
      # - The root node of the Abstract Syntax Tree (AST).
      #
      # Raises:
      # - Exception if there is a parse error.
      def parse(data, return_type = :string)
        tree = @parser.parse(data)

        raise Exception, "Parse error at offset: #{@parser.index} #{@parser.failure_reason}" if tree.nil?

        # This method edits the tree in place to remove unnecessary syntax nodes.
        clean_tree(tree)

        @tree = tree
        tree
      end

      # Recursively cleans the syntax tree by removing nodes of class 'Treetop::Runtime::SyntaxNode'.
      # This method is used to remove unnecessary nodes generated during parsing.
      def clean_tree(root_node)
        return if root_node.elements.nil?

        root_node.elements.delete_if { |node| node.class.name == 'Treetop::Runtime::SyntaxNode' }
        root_node.elements.each { |node| self.clean_tree(node) }
      end

      # Retrieves the root node of the IC service from the AST.
      #
      # Returns:
      # - The root node representing the IC service, or nil if not found.
      def ic_service
        tree.elements.each do |ele|
          return ele if ele.title == :ic_service
        end
        nil
      end

      # Retrieves an array of AST nodes representing IC type declarations.
      def ic_types
        type_arr = []
        tree.elements.each do |ele|
          type_arr << ele if ele.title == :type_declaration
        end
        type_arr
      end

      # Converts the IC type declarations to an array of corresponding objects.
      def ic_types_obj
        obj_arr = []
        ic_types.each do |ic_type|
          obj_arr << ic_type.to_obj
        end
        obj_arr
      end

      # Retrieves the root node of the IC service methods from the AST.
      #
      # Returns:
      # - The root node representing the IC service methods, or nil if not found.
      def ic_service_methods
        ic_service_tree = ic_service
        unless ic_service_tree.empty?
          ic_service_tree.elements.each do |ele|
            return ele if ele.title == :ic_service_methods
          end
        end
        nil
      end

      # Retrieves the name of an IC type from its AST node.
      def ic_type_name(ic_type)
        ic_type.type_param_name
      end

      # Retrieves an array of names of all IC types from the AST.
      def ic_type_names
        names_arr = []
        ic_types.each do |ic_type|
          names_arr << ic_type_name(ic_type)
        end
        names_arr
      end

      # Retrieves the AST node of an IC type by its name.
      #
      # Parameters:
      # - type_name: The name of the IC type to retrieve.
      #
      # Returns:
      # - The AST node representing the IC type, or nil if not found.
      def ic_type_by_name(type_name)
        ic_types.each do |ic_type|
          return ic_type if type_name == ic_type_name(ic_type)
        end
        nil
      end
    end
  end
end
