require 'rubytree'

module IcAgent
  class Canister
    def initialize(agent, canister_id, candid=nil)
      @agent = agent
      @canister_id = canister_id
      if candid
        @candid = candid
      else
        candid = @agent.query_raw(canister_id, '__get_candid_interface_tmp_hack', encode([]))
        @candid = candid[0]['value']
      end
      if candid.nil?
        puts candid
        puts 'Please provide candid description'
        raise BaseException, "canister #{@canister_id} has no __get_candid_interface_tmp_hack method."
      end

      parser = IcAgent::Ast::Parser.new
      parser.parse(@candid)

      ic_service_methods = parser.ic_service_methods.elements
      ic_service_methods.each do |item|
        service_method = item.to_obj
        method_name = service_method['ic_service_method_name']
        anno = service_method['ic_service_method_query']
        args = service_method['ic_service_method_params']
        rets = service_method['ic_service_method_return']

        args_arr = args.nil? ? [] : args.split(',').map(&:strip)
        args_type_arrs = []
        args_arr.each do |arg|
          args_type_arrs << get_param_to_ic_type(parser, arg)
        end
        ret_type = get_param_to_ic_type(parser, rets)

        add_caniter_method(method_name, args, args_type_arrs, ret_type, anno)
      end
    end

    private

    def service_param_child(parser, args_name, now_args = [], child_args = [], done_args = [])
      arg_opt = args_name.include?(' ') ? args_name.split(' ')[0] : args_name
      arg_child_item = []
      if IcAgent::Candid::ALL_TYPES.include?(arg_opt)
        arg_child_item = args_name.split(' ')[1..] if args_name.include?(' ')
      else
        input_body = parser.ic_type_by_name(arg_opt)
        input_body_obj = input_body.to_obj
        arg_child_item = input_body_obj['type_child_item_values']
        done_args << arg_opt
      end

      child_args = child_args + arg_child_item.flatten - done_args - IcAgent::Candid::ALL_TYPES
      child_args = child_args.uniq

      add_childs = child_args - now_args
      now_args += add_childs

      if child_args.length > 0
        next_args_name = child_args.pop
        return service_param_child(parser, next_args_name, now_args, child_args, done_args)
      end
      now_args
    end

    def build_param_tree(parser, type_name, current_node = nil, tree_root_node = nil)
      if current_node.nil?
        root_type = parser.ic_type_by_name(type_name)
        refer_nodes = root_type.type_child_refer_items.nil? ? [] : root_type.type_child_refer_items
        root_node = Tree::TreeNode.new(type_name,
                                       { 'total_child': refer_nodes.size,
                                         'all_child': refer_nodes,
                                         'child_refer': refer_nodes,
                                         'self_refer': false,
                                         'refer_path': [type_name],
                                         'ic_type': nil,
                                         'prototype': root_type.type_param_content,
                                         'content': root_type.type_param_content })
        tree_root_node = root_node
      else
        root_node = current_node
        refer_nodes = current_node.content[:child_refer]
      end

      if tree_root_node && current_node && tree_root_node.name != current_node.name && current_node.content[:child_refer].size == 0
        parent_node = current_node.parent
        parent_node.content[:child_refer].delete(current_node.name)
        # update parent ic types
        child_key_types = {}
        current_node.children.each do |child_node|
          child_key_types[child_node.name] = child_node.content[:ic_type]
        end
        ic_type = IcAgent::Ast::Assembler.build_type(current_node.content[:prototype], child_key_types)
        current_node.content[:ic_type] = ic_type


        # replace parent content
        new_content = replace_root_child_code(parent_node.content[:content], current_node.name, current_node.content[:content])
        parent_node.content[:content] = new_content

        # clear refer_path
        refer_index = tree_root_node.content[:refer_path].index(current_node.name)
        tree_root_node.content[:refer_path] = tree_root_node.content[:refer_path].slice(0, refer_index) if refer_index
        build_param_tree(parser, parent_node.name, parent_node, tree_root_node)
      end

      if tree_root_node.nil? || tree_root_node.content[:child_refer].size > 0
        if refer_nodes.size > 0
          refer_node = refer_nodes[0]
          # self refer
          if tree_root_node && tree_root_node.content[:refer_path].include?(refer_node)
            child_node = Tree::TreeNode.new(refer_node, { 'total_child': 0, 'child_refer': [], 'self_refer': true, 'content': nil })
            root_node << child_node
            root_node.content[:child_refer].delete(refer_node)
            build_param_tree(parser, root_node.name, root_node, tree_root_node)
          else
            # non self refer
            child_type = parser.ic_type_by_name(refer_node)
            child_refer_nodes = child_type.type_child_refer_items
            if child_refer_nodes.size == 0
              # set ic type
              ic_type = IcAgent::Ast::Assembler.build_type(child_type.type_param_content)
              child_node = Tree::TreeNode.new(refer_node, { 'total_child': 0,
                                                            'child_refer': [],
                                                            'self_refer': false,
                                                            'ic_type': ic_type,
                                                            'prototype': child_type.type_param_content,
                                                            'content': child_type.type_param_content })
              root_node << child_node
              root_node.content[:child_refer].delete(refer_node)

              # replace parent content
              new_content = replace_root_child_code(root_node.content[:content], refer_node, child_type.type_param_content)
              root_node.content[:content] = new_content
              build_param_tree(parser, root_node.name, root_node, tree_root_node)
            else
              child_node = Tree::TreeNode.new(refer_node, { 'total_child': child_refer_nodes.size,
                                                            'child_refer': child_refer_nodes,
                                                            'self_refer': false,
                                                            'prototype': child_type.type_param_content,
                                                            'content': child_type.type_param_content })
              root_node << child_node
              tree_root_node.content[:all_child] = (tree_root_node.content[:all_child] + child_refer_nodes).uniq

              # add refer_path
              tree_root_node.content[:refer_path] << refer_node
              build_param_tree(parser, refer_node, child_node, tree_root_node)
            end
          end
        end
      end

      # update root_node ic types
      if root_node.content[:ic_type].nil?
        child_key_types = {}
        root_node.children.each do |child_node|
          child_key_types[child_node.name] = child_node.content[:ic_type]
        end
        ic_type = IcAgent::Ast::Assembler.build_type(root_node.content[:prototype], child_key_types)
        root_node.content[:ic_type] = ic_type
      end

      root_node
    end

    # params array recursively call, traverse, and replace
    def service_params_replace(arr, search_value, replace_value)
      arr.map! do |element|
        if element.is_a?(Array)
          service_params_replace(element, search_value, replace_value)
        else
          element == search_value ? replace_value : element
        end
      end
    end

    def refer_type(param)
      param_arr = param.strip.split(' ')
      refer_type = param_arr - IcAgent::Candid::ALL_TYPES
      refer_type.empty? ? nil : refer_type[0]
    end

    def only_refer_type?(param)
      refer_types = IcAgent::Ast::Assembler.get_params_refer_values(param)
      param.index(' ').nil? && refer_types.size == 1
    end

    def get_param_to_ic_type(parser, param)
      ic_refer_types = {}
      refer_types = IcAgent::Ast::Assembler.get_params_refer_values(param)
      refer_types.each do |refer_code|
        ic_refer_types[refer_code] = build_param_tree(parser, refer_code, nil, nil).content[:ic_type]
      end

      ic_type = nil
      if param.index(' ') || refer_types.size > 1
        ic_type = IcAgent::Ast::Assembler.build_type(param, ic_refer_types)
      elsif ic_refer_types.keys.size == 1
        ic_type = ic_refer_types.values[0]
      end
      ic_type
    end

    def decode_type_arg(parser, arg)
      base_arg = arg.strip
      decode_arg = base_arg
      unless base_arg.include?(' ') || IcAgent::Candid::ALL_TYPES.any? { |str| base_arg.include?(str) }
        arg_type = parser.ic_type_by_name(base_arg)
        decode_arg = arg_type.type_param_content
      end
      decode_arg
    end

    def replace_root_child_code(root_text, find_text, replace_text)
      new_root_text = root_text
      parts = new_root_text.split(";")

      if parts.size > 0
        parts.map do |part|
          last_index = part.rindex(find_text)
          e_last_index = part.rindex("#{find_text}}")
          b_last_index = part.rindex("#{find_text} ")
          part[last_index..(last_index + find_text.size - 1)] = replace_text if last_index && (e_last_index || b_last_index || (last_index + find_text.size) == part.size)
        end
        new_root_text = parts.join(";")
      else
        last_index = new_root_text.rindex(find_text)
        e_last_index = new_root_text.rindex("#{find_text}}")
        b_last_index = new_root_text.rindex("#{find_text} ")
        new_root_text[last_index..(last_index + find_text.size - 1)] = replace_text if last_index && (e_last_index || b_last_index || (last_index + find_text.size) == part.size)
      end
      new_root_text
    end

    def add_caniter_method(method_name, type_args, args_types, rets_type, anno = nil)
      self.class.class_eval do
        define_method(method_name) do |*args|
          init_method_name = method_name
          init_method_args = type_args.nil? ? [] : type_args.split(',').map(&:strip)
          init_method_anno = anno
          init_method_types = args_types
          init_method_ret_type = rets_type

          if init_method_args.length != args.length
            raise ArgumentError, 'Arguments length not match'
          end

          arguments = []
          args.each_with_index do |arg, i|
            arguments << { 'type': init_method_types[i], 'value': arg }
          end

          effective_canister_id = @canister_id == 'aaaaa-aa' && init_method_args.length > 0 && init_method_args[0].is_a?(Hash) && init_method_args[0].key?('canister_id') ? init_method_args[0]['canister_id'] : @canister_id
          res = if init_method_anno == 'query'
                  @agent.query_raw(@canister_id, init_method_name, IcAgent::Candid.encode(arguments), init_method_ret_type, effective_canister_id)
                else
                  @agent.update_raw(@canister_id, init_method_name, IcAgent::Candid.encode(arguments), init_method_ret_type, effective_canister_id)
                end
          return res unless res.is_a?(Array)

          res.map { |item| item['value'] }
        end
      end
    end
  end
end

