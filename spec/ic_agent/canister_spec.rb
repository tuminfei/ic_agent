require 'spec_helper'
require 'byebug'

describe IcAgent::Canister do
  before(:all) do
    iden = IcAgent::Identity.new
    client = IcAgent::Client.new
    @agent = IcAgent::Agent.new(iden, client)
    @subnet_key = '308182301d060d2b0601040182dc7c0503010201060c2b0601040182dc7c05030201036100b31b406c9f6648695a88154ae2e4f5fe87883d4ad81c2844c5571b2d91d401cdd40836e763a7c18dccb84629b0d808f7142c3175bc8231dc09bd53637efd6f2568801385ec973d34e6eef9c8c8280a9f4a114163a43a8540941ba367f0c7cb28'
    @gov_canister_id = 'rrkah-fqaaa-aaaaa-aaaaq-cai'
    @gov_didl = <<~DIDL_DOC
      service : (Governance) -> {
        claim_gtc_neurons : (principal, vec NeuronId) -> (Result) query;
        claim_or_refresh_neuron_from_account : (ClaimOrRefreshNeuronFromAccount) -> (ClaimOrRefreshNeuronFromAccountResponse) query;
        get_full_neuron : (nat64) -> (Result_2) query;
        get_full_neuron_by_id_or_subaccount : (NeuronIdOrSubaccount) -> (Result_2);
        get_monthly_node_provider_rewards : () -> (Result_3) query;
        get_neuron_ids : () -> (nat64) query;
        get_neuron_info : (nat64) -> (Result_4) query;
        get_neuron_info_by_id_or_subaccount : (NeuronIdOrSubaccount) -> (Result_4) query;
        get_pending_proposals : () -> (ProposalInfo) query;
        get_proposal_info : (nat64) -> (ProposalInfo) query;
        list_known_neurons : () -> (ListKnownNeuronsResponse) query;
        list_neurons : (ListNeurons) -> (ListNeuronsResponse) query;
        list_proposals : (ListProposalInfo) -> (ListProposalInfoResponse) query;
        manage_neuron : (ManageNeuron) -> (ManageNeuronResponse) query;
        transfer_gtc_neuron : (NeuronId, NeuronId) -> (Result) query;
        update_node_provider : (UpdateNodeProvider) -> (Result) query;
      }
    DIDL_DOC
  end

  it 'didl factory' do
    parser = IcAgent::Ast::Parser.new
    parser.parse(@gov_didl)
  end

  it 'IcAgent::Canister call' do
    gov = IcAgent::Canister.new(@agent, @gov_canister_id, @gov_didl)
  end
end



