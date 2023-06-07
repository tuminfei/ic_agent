module IcAgent
  module Common
    class Ledger
      CANISTER_ID = 'ryjl3-tyaaa-aaaaa-aaaba-cai'
      DID_FILE = <<~DIDL_DOC
        // This is the official Ledger interface that is guaranteed to be backward compatible.

        // Amount of tokens, measured in 10^-8 of a token.
        type Tokens = record {
             e8s : nat64;
        };

        // Number of nanoseconds from the UNIX epoch in UTC timezone.
        type TimeStamp = record {
            timestamp_nanos: nat64;
        };

        // AccountIdentifier is a 32-byte array.
        // The first 4 bytes is big-endian encoding of a CRC32 checksum of the last 28 bytes.
        type AccountIdentifier = blob;

        // Subaccount is an arbitrary 32-byte byte array.
        // Ledger uses subaccounts to compute the source address, which enables one
        // principal to control multiple ledger accounts.
        type SubAccount = blob;

        // Sequence number of a block produced by the ledger.
        type BlockIndex = nat64;

        // An arbitrary number associated with a transaction.
        // The caller can set it in a `transfer` call as a correlation identifier.
        type Memo = nat64;

        // Arguments for the `transfer` call.
        type TransferArgs = record {
            memo: Memo;
            amount: Tokens;
            fee: Tokens;
            from_subaccount: opt SubAccount;
            to: AccountIdentifier;
            created_at_time: opt TimeStamp;
        };

        type TransferError = variant {
            BadFee : record { expected_fee : Tokens; };
            InsufficientFunds : record { balance: Tokens; };
            TxTooOld : record { allowed_window_nanos: nat64 };
            TxCreatedInFuture : null;
            TxDuplicate : record { duplicate_of: BlockIndex; }
        };

        type TransferResult = variant {
            Ok : BlockIndex;
            Err : TransferError;
        };

        // Arguments for the `account_balance` call.
        type AccountBalanceArgs = record {
            account: AccountIdentifier;
        };

        type TransferFeeArg = record {};

        type TransferFee = record {
            transfer_fee: Tokens;
        };

        type GetBlocksArgs = record {
            start : BlockIndex;
            length : nat64;
        };

        type Operation = variant {
            Mint : record {
                to : AccountIdentifier;
                amount : Tokens;
            };
            Burn : record {
                from : AccountIdentifier;
                amount : Tokens;
            };
            Transfer : record {
                from : AccountIdentifier;
                to : AccountIdentifier;
                amount : Tokens;
                fee : Tokens;
            };
        };

        type Transaction = record {
            memo : Memo;
            operation : opt Operation;
            created_at_time : TimeStamp;
        };

        type Block = record {
            parent_hash : opt blob;
            transaction : Transaction;
            timestamp : TimeStamp;
        };

        // A prefix of the block range specified in the [GetBlocksArgs] request.
        type BlockRange = record {
            blocks : vec Block;
        };

        // An error indicating that the arguments passed to [QueryArchiveFn] were invalid.
        type QueryArchiveError = variant {
            BadFirstBlockIndex : record {
                requested_index : BlockIndex;
                first_valid_index : BlockIndex;
            };
            Other : record {
                error_code : nat64;
                error_message : text;
            };
        };

        type QueryArchiveResult = variant {
            Ok : BlockRange;
            Err : QueryArchiveError;
        };

        // A function that is used for fetching archived ledger blocks.
        type QueryArchiveFn = func (GetBlocksArgs) -> (QueryArchiveResult) query;

        // The result of a "query_blocks" call.
        //
        // The structure of the result is somewhat complicated because the main ledger canister might
        // not have all the blocks that the caller requested: One or more "archive" canisters might
        // store some of the requested blocks.
        //
        // Note: as of Q4 2021 when this interface is authored, the IC doesn't support making nested 
        // query calls within a query call.
        type QueryBlocksResponse = record {
            chain_length : nat64;
            certificate : opt blob;
            blocks : vec Block;
            first_block_index : BlockIndex;
            archived_blocks : vec record {
                start : BlockIndex;
                length : nat64;
                callback : QueryArchiveFn;
            };
        };

        type Archive = record {
            canister_id: principal;
        };

        type Archives = record {
            archives: vec Archive;
        };

        service : {
          transfer : (TransferArgs) -> (TransferResult);
          account_balance : (AccountBalanceArgs) -> (Tokens) query;
          transfer_fee : (TransferFeeArg) -> (TransferFee) query;
          query_blocks : (GetBlocksArgs) -> (QueryBlocksResponse) query;
          symbol : () -> (record { symbol: text }) query;
          name : () -> (record { name: text }) query;
          decimals : () -> (record { decimals: nat32 }) query;
          archives : () -> (Archives) query;
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
