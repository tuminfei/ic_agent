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
      ic_type_names = parser.ic_type_names

      ic_service_methods.each do |item|
        service_method = item.to_obj
        method_name = service_method['ic_service_method_name']
        anno = service_method['ic_service_method_query']
        args = service_method['ic_service_method_params']
        rets = service_method['ic_service_method_return']

        args_arr = args.nil? ? [] : args.split(',').map(&:strip)
        args_type_arrs = []
        args_arr.each do |arg|
          arr_arg = arg.split(' ').map(&:strip)
          opt_code = arr_arg[0]
          child_item = arr_arg.size > 0 ? arr_arg[1..] : []

          if IcAgent::Candid::ALL_TYPES.include?(opt_code)
            args_type_arrs << service_params(parser, ic_type_names, nil, opt_code, child_item)
          else
            args_type_arrs << service_params(parser, ic_type_names, arg)
          end
        end
        # rets_type_arrs = service_params(parser, ic_type_names, rets)

        add_caniter_method(method_name, args, rets, anno)
      end
    end

    private

    def service_params(parser, ic_type_names, args_name, arg_opt_code = nil, arg_child_item = [], now_args = {}, child_args = [])
      # logger = Logger.new("logger.txt")
      # logger.info("#{args_name}::::#{arg_opt_code}")
      if args_name.nil?
        opt_code = arg_opt_code
        child_item = arg_child_item
      else
        input_body = parser.ic_type_by_name(args_name)
        input_body_obj = input_body.to_obj
        opt_code = input_body_obj['type_root_opt_code']
        child_item = input_body_obj['type_child_item_values']
      end

      tree_code = now_args.key?('root') ? 'child' : 'root'

      if IcAgent::Candid::MULTI_TYPES.include? opt_code || child_args.length > 0
        if tree_code == 'root'
          now_args[tree_code] = [opt_code, child_item]
        else
          now_args[tree_code] = {} if now_args[tree_code].nil?
          now_args[tree_code][args_name] = [opt_code, child_item]
        end

        child_args = child_args + child_item.flatten - IcAgent::Candid::SINGLE_TYPES - IcAgent::Candid::MULTI_TYPES
        child_args = child_args.uniq
        now_child_keys = now_args['child'].nil? ? [] : now_args['child'].keys
        # filter out non-existing types
        lost_args = child_args - ic_type_names
        child_args = child_args - lost_args - now_child_keys

        if child_args.length > 0
          next_args_name = child_args.pop
          return service_params(parser, ic_type_names, next_args_name, nil, [], now_args, child_args)
        end
      else
        now_args[tree_code] = [opt_code, nil]
      end
      now_args
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

    def add_caniter_method(method_name, type_args, rets, anno = nil)
      self.class.class_eval do
        define_method(method_name) do |*args|
          init_method_name = method_name
          init_method_args = type_args.split(',').map(&:strip)
          init_method_rets = rets
          init_method_anno = anno

          if init_method_args.length != args.length
            raise ArgumentError, 'Arguments length not match'
          end

          arguments = []
          args.each_with_index do |arg, i|
            arguments << { 'type' => init_method_args[i], 'value' => arg }
          end

          effective_canister_id = @canister_id == 'aaaaa-aa' && init_method_args.length > 0 && init_method_args[0].is_a?(Hash) && init_method_args[0].key?('canister_id') ? init_method_args[0]['canister_id'] : @canister_id
          res = if init_method_anno == 'query'
                  @agent.query_raw(@canister_id, init_method_name, IcAgent::Candid.encode(arguments), init_method_rets, effective_canister_id)
                else
                  @agent.update_raw(@canister_id, init_method_name, IcAgent::Candid.encode(arguments), init_method_rets, effective_canister_id)
                end

          return res unless res.is_a?(Array)

          res.map { |item| item['value'] }
        end
      end
    end
  end
end

