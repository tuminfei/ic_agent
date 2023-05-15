require 'did_parser'

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

      input_stream = DIDParser::Parser.lexer(@candid)
      lexer = DIDLexer.new(input_stream)
      token_stream = Antlr4::CommonTokenStream.new(lexer)
      parser = DIDParser.new(token_stream)
      tree = parser.program

      emitter = DIDEmitter.new
      walker = Antlr4::Runtime::Tree::ParseTreeWalker.new
      walker.walk(emitter, tree)

      @actor = emitter.get_actor

      @actor['methods'].each do |name, method|
        raise TypeError, 'method must be FuncClass' unless method.is_a?(FuncClass)
        anno = method.annotations.empty? ? nil : method.annotations[0]
        method_obj = CaniterMethod.new(agent, canister_id, name, method.argTypes, method.retTypes, anno)
        instance_variable_set("@#{name}", method_obj)
        self.class.send(:attr_accessor, name)
      end
    end
  end

  class CaniterMethod
    def initialize(agent, canister_id, name, args, rets, anno=nil)
      @agent = agent
      @canister_id = canister_id
      @name = name
      @args = args
      @rets = rets

      @anno = anno
    end

    def call(*args, **kwargs)
      if args.length != @args.length
        raise ArgumentError, 'Arguments length not match'
      end
      arguments = []
      args.each_with_index do |arg, i|
        arguments << { 'type' => @args[i], 'value' => arg }
      end

      effective_canister_id = @canister_id == 'aaaaa-aa' && args.length > 0 && args[0].is_a?(Hash) && args[0].key?('canister_id') ? args[0]['canister_id'] : @canister_id
      if @anno == 'query'
        res = @agent.query_raw(
          @canister_id,
          @name,
          encode(arguments),
          @rets,
          effective_canister_id
        )
      else
        res = @agent.update_raw(
          @canister_id,
          @name,
          encode(arguments),
          @rets,
          effective_canister_id
        )
      end

      return res unless res.is_a?(Array)
      res.map { |item| item['value'] }
    end
  end
end

