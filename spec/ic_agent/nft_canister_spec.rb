require 'spec_helper'

describe IcAgent::Canister do
  before(:all) do
    iden = IcAgent::Identity.new
    client = IcAgent::Client.new
    @agent = IcAgent::Agent.new(iden, client)
    @subnet_key = '308182301d060d2b0601040182dc7c0503010201060c2b0601040182dc7c05030201036100b31b406c9f6648695a88154ae2e4f5fe87883d4ad81c2844c5571b2d91d401cdd40836e763a7c18dccb84629b0d808f7142c3175bc8231dc09bd53637efd6f2568801385ec973d34e6eef9c8c8280a9f4a114163a43a8540941ba367f0c7cb28'
    @nft_canister_id = 'zri47-daaaa-aaaah-adjzq-cai'
    @nft_didl = <<~DIDL_DOC
      type User = 
       variant {
         address: AccountIdentifier;
         principal: principal;
       };
      type TransferResponse = 
       variant {
         err:
          variant {
            CannotNotify: AccountIdentifier;
            InsufficientBalance;
            InvalidToken: TokenIdentifier;
            Other: text;
            Rejected;
            Unauthorized: AccountIdentifier;
          };
         ok: Balance;
       };
      type TransferRequest = 
       record {
         amount: Balance;
         from: User;
         memo: Memo;
         notify: bool;
         subaccount: opt SubAccount;
         to: User;
         token: TokenIdentifier;
       };
      type TokenIndex = nat32;
      type TokenIdentifier__1 = text;
      type TokenIdentifier = text;
      type Time = int;
      type SubAccount = vec nat8;
      type Result__1_2 = 
       variant {
         err: CommonError;
         ok: Balance__1;
       };
      type Result__1_1 = 
       variant {
         err: CommonError;
         ok: AccountIdentifier__1;
       };
      type Result__1 = 
       variant {
         err: CommonError;
         ok: Metadata;
       };
      type Result_2 = 
       variant {
         err: CommonError;
         ok: Balance__1;
       };
      type Result_1 = 
       variant {
         err: CommonError;
         ok: vec TokenIndex;
       };
      type Result = 
       variant {
         err: CommonError;
         ok: vec record {
                   TokenIndex;
                   opt Listing;
                   opt blob;
                 };
       };
      type Property = 
       record {
         trait_type: text;
         value: text;
       };
      type MintRequest = 
       record {
         metadata: opt blob;
         to: User;
       };
      type MetadataStorageType = 
       variant {
         Fleek;
         Last;
         MetaBox;
         S3;
       };
      type MetadataStorageInfo = 
       record {
         environmentImageThree: text;
         thumb: text;
         url: text;
       };
      type Metadata = 
       variant {
         fungible:
          record {
            decimals: nat8;
            metadata: opt blob;
            name: text;
            symbol: text;
          };
         nonfungible: record { metadata: opt blob; };
       };
      type Memo = blob;
      type Listing = 
       record {
         locked: opt Time;
         price: nat64;
         seller: principal;
       };
      type HttpResponse = 
       record {
         body: blob;
         headers: vec HeaderField;
         status_code: nat16;
       };
      type HttpRequest = 
       record {
         body: blob;
         headers: vec HeaderField;
         method: text;
         url: text;
       };
      type HeaderField = 
       record {
         text;
         text;
       };
      type Extension = text;
      type CommonError__1 = 
       variant {
         InvalidToken: TokenIdentifier;
         Other: text;
       };
      type CommonError = 
       variant {
         InvalidToken: TokenIdentifier;
         Other: text;
       };
      type Balance__1 = nat;
      type BalanceResponse = 
       variant {
         err: CommonError__1;
         ok: Balance;
       };
      type BalanceRequest = 
       record {
         token: TokenIdentifier;
         user: User;
       };
      type Balance = nat;
      type ApproveRequest = 
       record {
         allowance: Balance;
         spender: principal;
         subaccount: opt SubAccount;
         token: TokenIdentifier;
       };
      type AllowanceRequest = 
       record {
         owner: User;
         spender: principal;
         token: TokenIdentifier;
       };
      type AccountIdentifier__1 = text;
      type AccountIdentifier = text;
      service : {
        acceptCycles: () -> ();
        addMetadataStorageType: (text) -> () oneway;
        addMetadataUrlMany:
         (vec record {
                MetadataStorageType;
                TokenIndex;
                MetadataStorageInfo;
              }) -> () oneway;
        allowance: (AllowanceRequest) -> (Result__1_2) query;
        approve: (ApproveRequest) -> (bool);
        approveAll: (vec ApproveRequest) -> (vec TokenIndex);
        availableCycles: () -> (nat) query;
        balance: (BalanceRequest) -> (BalanceResponse) query;
        batchMintNFT: (vec MintRequest) -> (vec TokenIndex);
        batchTransfer: (vec TransferRequest) -> (vec TransferResponse);
        bearer: (TokenIdentifier__1) -> (Result__1_1) query;
        clearProperties: () -> () oneway;
        deleteMetadataStorageType: (text) -> () oneway;
        extensions: () -> (vec Extension) query;
        getAdmin: () -> (principal) query;
        getAllowances: () -> (vec record {
                                    TokenIndex;
                                    principal;
                                  }) query;
        getMedataStorageType: () -> (vec text);
        getMinter: () -> (principal) query;
        getProperties: () -> (vec record { text; vec record { text; nat; };}) query;
        getRegistry: () -> (vec record {
                                  TokenIndex;
                                  AccountIdentifier__1;
                                }) query;
        getRootBucketId: () -> (opt text);
        getScore: () -> (vec record {
                               TokenIndex;
                               float64;
                             }) query;
        getStorageMetadataUrl: (MetadataStorageType, TokenIndex) ->
         (record {
            text;
            text;
            text;
          });
        getTokens: () -> (vec record {
                                TokenIndex;
                                Metadata;
                              }) query;
        getTokensByIds: (vec TokenIndex) ->
         (vec record {
                TokenIndex;
                Metadata;
              }) query;
        getTokensByProperties: (vec record {
                                      text;
                                      vec text;
                                    }) -> (vec record {
                                                 TokenIndex;
                                                 Metadata;
                                               }) query;
        http_request: (HttpRequest) -> (HttpResponse) query;
        initCap: () -> (opt text);
        initLastMetadata: (TokenIndex, TokenIndex) -> ();
        initproperties: (TokenIndex, TokenIndex) -> ();
        lookProperties: () -> (vec record {
                                     Property;
                                     vec TokenIndex;
                                   }) query;
        lookPropertyScoreByTokenId: () ->
         (vec record {
                TokenIndex;
                vec record {
                      Property;
                      int64;
                    };
              }) query;
        metadata: (TokenIdentifier__1) -> (Result__1) query;
        mintNFT: (MintRequest) -> (TokenIndex);
        replaceMetadata: (MetadataStorageType, TokenIndex, TokenIndex) -> ();
        setCanTransfer: (bool) -> (bool);
        setMinter: (principal) -> ();
        setScoreOfTokenId: (int64) -> ();
        setSuperController: (principal) -> ();
        supply: (TokenIdentifier__1) -> (Result_2) query;
        tokens: (AccountIdentifier__1) -> (Result_1) query;
        tokens_ext: (AccountIdentifier__1) -> (Result) query;
        transfer: (TransferRequest) -> (TransferResponse);
        updateMetadata: (vec record {
                               TokenIndex;
                               opt blob;
                             }) -> ();
        updateNFTName: (text, text, TokenIndex, TokenIndex) -> ();
      }
    DIDL_DOC
  end

  it 'didl factory' do
    parser = IcAgent::Ast::Parser.new
    parser.parse(@nft_didl)
    ic_type = parser.ic_type_by_name('HeaderField')
    expect(ic_type.title).to eql(:type_declaration)
    expect(ic_type.type_param_name).to eql('HeaderField')
  end

  it 'IcAgent::Canister call' do
    nft = IcAgent::Canister.new(@agent, @nft_canister_id, @nft_didl)
    res = nft.getTokens()
    expect(res[0].size).to be > 1
  end
end



