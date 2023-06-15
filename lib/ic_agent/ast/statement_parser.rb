require 'treetop'

module IcAgent
  module Ast
    class StatementParser
      attr_accessor :parser, :tree, :source_tree

      REFER_TYPE_CLASS = ['IcAgent::Ast::Nodes::IcBaseTypeRecord',
                          'IcAgent::Ast::Nodes::IcBaseTypeVariant',
                          'IcAgent::Ast::Nodes::IcBaseTypeVec',
                          'IcAgent::Ast::Nodes::IcBaseTypeOpt']

      TREE_TYPE_CLASS = ['IcAgent::Ast::Nodes::IcBaseTypeRecord',
                         'IcAgent::Ast::Nodes::IcBaseTypeVariant',
                         'IcAgent::Ast::Nodes::IcBaseTypeVec',
                         'IcAgent::Ast::Nodes::IcBaseTypeFunc',
                         'IcAgent::Ast::Nodes::IcBaseTypeOpt',
                         'IcAgent::Ast::Nodes::IcBaseTypeSingle',
                         'IcAgent::Ast::Nodes::IcBaseTypeOther']

      REFER_TYPE_KEYS = ['record', 'variant']

      def initialize
        Treetop.load(File.expand_path(File.join(File.dirname(__FILE__), 'nested_type_grammar.treetop')))
        @parser = TypeGrammarParser.new
      end

      def parse(data, return_type = :string)
        tree = @parser.parse(data)
        raise Exception, "Parse error at offset: #{@parser.index} #{@parser.failure_reason}" if tree.nil?


        # this edits the tree in place
        clean_tree(tree)
        # generate soure tree
        gen_source_tree(tree)
        @tree = tree
        tree
      end

      def clean_tree(root_node)
        return if root_node.elements.nil?

        root_node.elements.delete_if { |node| node.class.name == 'Treetop::Runtime::SyntaxNode' and node.parent.class.name != 'IcAgent::Ast::Nodes::IcBaseTypeValue' and node.parent.class.name != "IcAgent::Ast::Nodes::IcTypeDef" }
        root_node.elements.each { |node| self.clean_tree(node) }
      end

      # @param [Object] root_node
      # @param [nil] tree_root_node
      # @param [nil] tree_current_node
      def gen_source_tree(root_node, tree_root_node = nil, tree_current_node = nil)
        return if root_node.elements.nil?

        tree_root_node = tree_root_node.nil? ? Tree::TreeNode.new('root', { 'total_child': 0, 'ic_type': nil, 'refer_type': [], 'prototype': root_node.source_content, 'content': root_node.source_content }) : tree_root_node
        tree_current_node = tree_current_node.nil? ? tree_root_node : tree_current_node

        root_node.elements.each do |node|
          if TREE_TYPE_CLASS.include?(node.class.name) && node.source_content != tree_root_node.content[:prototype]

            id = tree_root_node.content[:total_child] + 1
            new_tree_node = Tree::TreeNode.new("node_#{id}", { 'total_child': 0, 'ic_type': nil, 'prototype': root_node.source_content, 'content': root_node.source_content })
            tree_current_node << new_tree_node
            tree_root_node.content[:total_child] = id

            # set refer_type
            unless Regexp.union(REFER_TYPE_KEYS) === root_node.source_content
              param_arr = root_node.source_content.strip.split(' ').collect { |v| v.strip.gsub(';', '') }
              param_arr = param_arr - IcAgent::Candid::ALL_TYPES
              tree_root_node.content[:refer_type] = (tree_root_node.content[:refer_type] + param_arr).uniq
            end

            self.source_tree = tree_root_node
            self.gen_source_tree(node, tree_root_node, new_tree_node)
          else
            self.gen_source_tree(node, tree_root_node, tree_current_node)
          end
        end

        self.source_tree = tree_root_node
      end

      def ic_statement_root
        tree.elements[0]
      end

      def ic_statement_childs
        if tree.elements[0] && tree.elements[0].elements[0].elements[0]
          tree.elements[0].elements[0].elements[0].elements
        end
      end
    end
  end
end
