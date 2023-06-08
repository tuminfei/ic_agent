module IcAgent
  module Common
    class Management
      CANISTER_ID = 'aaaaa-aa'
      DID_FILE = <<~DIDL_DOC
        type canister_id = principal;
        type user_id = principal;
        type wasm_module = blob;

        type canister_settings = record {
          controllers : opt vec principal;
          compute_allocation : opt nat;
          memory_allocation : opt nat;
          freezing_threshold : opt nat;
        };

        type definite_canister_settings = record {
          controllers : vec principal;
          compute_allocation : nat;
          memory_allocation : nat;
          freezing_threshold : nat;
        };

        service ic : {
          create_canister : (record {
            settings : opt canister_settings
          }) -> (record {canister_id : canister_id});
          update_settings : (record {
            canister_id : principal;
            settings : canister_settings
          }) -> ();
          install_code : (record {
            mode : variant {install; reinstall; upgrade};
            canister_id : canister_id;
            wasm_module : wasm_module;
            arg : blob;
          }) -> ();
          uninstall_code : (record {canister_id : canister_id}) -> ();
          start_canister : (record {canister_id : canister_id}) -> ();
          stop_canister : (record {canister_id : canister_id}) -> ();
          canister_status : (record {canister_id : canister_id}) -> (record {
              status : variant { running; stopping; stopped };
              settings: definite_canister_settings;
              module_hash: opt blob;
              memory_size: nat;
              cycles: nat;
          });
          delete_canister : (record {canister_id : canister_id}) -> ();
          deposit_cycles : (record {canister_id : canister_id}) -> ();
          provisional_create_canister_with_cycles : (record {
            amount: opt nat;
            settings : opt canister_settings
          }) -> (record {canister_id : canister_id});
          provisional_top_up_canister :
            (record { canister_id: canister_id; amount: nat }) -> ();
        }
      DIDL_DOC

      attr_accessor :identity, :client, :agent, :canister

      def initialize(iden = nil)
        @identity = iden.nil? ? IcAgent::Identity.new : iden
        @client = IcAgent::Client.new
        @agent = IcAgent::Agent.new(@identity, @client)
        @canister = IcAgent::Canister.new(@agent, CANISTER_ID, DID_FILE)
      end
    end
  end
end