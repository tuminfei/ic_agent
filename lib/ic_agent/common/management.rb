module IcAgent
  module Common
    class Management
      CANISTER_ID = 'aaaaa-aa'
      DID_FILE = <<~DIDL_DOC
        type canister_id = principal;
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

        type change_origin = variant {
          from_user : record {
            user_id : principal;
          };
          from_canister : record {
            canister_id : principal;
            canister_version : opt nat64;
          };
        };

        type change_details = variant {
          creation : record {
            controllers : vec principal;
          };
          code_uninstall;
          code_deployment : record {
            mode : variant {install; reinstall; upgrade};
            module_hash : blob;
          };
          controllers_change : record {
            controllers : vec principal;
          };
        };

        type change = record {
          timestamp_nanos : nat64;
          canister_version : nat64;
          origin : change_origin;
          details : change_details;
        };

        type http_header = record { name: text; value: text };

        type ecdsa_curve = variant { secp256k1; };

        type satoshi = nat64;

        type bitcoin_network = variant {
          mainnet;
          testnet;
        };

        type bitcoin_address = text;

        type block_hash = blob;

        type outpoint = record {
          txid : blob;
          vout : nat32
        };

        type utxo = record {
          outpoint: outpoint;
          value: satoshi;
          height: nat32;
        };

        type get_utxos_request = record {
          address : bitcoin_address;
          network: bitcoin_network;
          filter: opt variant {
            min_confirmations: nat32;
            page: blob;
          };
        };

        type get_current_fee_percentiles_request = record {
          network: bitcoin_network;
        };

        type get_utxos_response = record {
          utxos: vec utxo;
          tip_block_hash: block_hash;
          tip_height: nat32;
          next_page: opt blob;
        };

        type get_balance_request = record {
          address : bitcoin_address;
          network: bitcoin_network;
          min_confirmations: opt nat32;
        };

        type send_transaction_request = record {
          transaction: blob;
          network: bitcoin_network;
        };

        type millisatoshi_per_byte = nat64;

        service : {
          create_canister : (record {
            settings : opt canister_settings;
            sender_canister_version : opt nat64;
          }) -> (record {canister_id : canister_id});
          update_settings : (record {
            canister_id : principal;
            settings : canister_settings;
            sender_canister_version : opt nat64;
          }) -> ();
          install_code : (record {
            mode : variant {install; reinstall; upgrade};
            canister_id : canister_id;
            wasm_module : wasm_module;
            arg : blob;
            sender_canister_version : opt nat64;
          }) -> ();
          uninstall_code : (record {
            canister_id : canister_id;
            sender_canister_version : opt nat64;
          }) -> ();
          start_canister : (record {canister_id : canister_id}) -> ();
          stop_canister : (record {canister_id : canister_id}) -> ();
          canister_status : (record {canister_id : canister_id}) -> (record {
              status : variant { running; stopping; stopped };
              settings: definite_canister_settings;
              module_hash: opt blob;
              memory_size: nat;
              cycles: nat;
              idle_cycles_burned_per_day: nat;
          });
          canister_info : (record {
              canister_id : canister_id;
              num_requested_changes : opt nat64;
          }) -> (record {
              total_num_changes : nat64;
              recent_changes : vec change;
              module_hash : opt blob;
              controllers : vec principal;
          });
          delete_canister : (record {canister_id : canister_id}) -> ();
          deposit_cycles : (record {canister_id : canister_id}) -> ();
          raw_rand : () -> (blob);

          ecdsa_public_key : (record {
            canister_id : opt canister_id;
            derivation_path : vec blob;
            key_id : record { curve: ecdsa_curve; name: text };
          }) -> (record { public_key : blob; chain_code : blob; });
          sign_with_ecdsa : (record {
            message_hash : blob;
            derivation_path : vec blob;
            key_id : record { curve: ecdsa_curve; name: text };
          }) -> (record { signature : blob });

          bitcoin_get_balance: (get_balance_request) -> (satoshi);
          bitcoin_get_utxos: (get_utxos_request) -> (get_utxos_response);
          bitcoin_send_transaction: (send_transaction_request) -> ();
          bitcoin_get_current_fee_percentiles: (get_current_fee_percentiles_request) -> (vec millisatoshi_per_byte);

          provisional_create_canister_with_cycles : (record {
            amount: opt nat;
            settings : opt canister_settings;
            specified_id: opt canister_id;
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