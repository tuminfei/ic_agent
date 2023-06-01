require 'treetop'

module IcAgent
  module Ast
    class Parser
      attr_accessor :parser, :tree

      def initialize
        Treetop.load(File.expand_path(File.join(File.dirname(__FILE__), 'did_grammar.treetop')))
        @parser = DIDGrammarParser.new
      end

      def parse(data, return_type = :string)
        tree = @parser.parse(data)

        raise Exception, "Parse error at offset: #{@parser.index} #{@parser.failure_reason}" if tree.nil?

        # this edits the tree in place
        clean_tree(tree)

        @tree = tree
        tree
      end

      def clean_tree(root_node)
        return if root_node.elements.nil?

        root_node.elements.delete_if { |node| node.class.name == 'Treetop::Runtime::SyntaxNode' }
        root_node.elements.each { |node| self.clean_tree(node) }
      end

      def ic_service
        tree.elements.each do |ele|
          return ele if ele.title == :ic_service
        end
        nil
      end

      def ic_types
        type_arr = []
        tree.elements.each do |ele|
          type_arr << ele if ele.title == :type_declaration
        end
        type_arr
      end

      def ic_types_obj
        obj_arr = []
        ic_types.each do |ic_type|
          obj_arr << ic_type.to_obj
        end
        obj_arr
      end

      def ic_service_methods
        ic_service_tree = ic_service
        unless ic_service_tree.empty?
          ic_service_tree.elements.each do |ele|
            return ele if ele.title == :ic_service_methods
          end
        end
        nil
      end

      def ic_type_name(ic_type)
        ic_type.type_param_name
      end

      def ic_type_names
        names_arr = []
        ic_types.each do |ic_type|
          names_arr << ic_type_name(ic_type)
        end
        names_arr
      end

      def ic_type_by_name(type_name)
        ic_types.each do |ic_type|
          return ic_type if type_name == ic_type_name(ic_type)
        end
        nil
      end
    end
  end
end
