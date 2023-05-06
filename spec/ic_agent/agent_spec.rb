require 'spec_helper'

describe IcAgent::Agent do
  it 'IcAgent::Agent call' do
    iden = IcAgent::Identity.new(privkey = '833fe62409237b9d62ec77587520911e9a759cec1d19755b7da901b96dca3d42')
    client = IcAgent::Client.new
    agent = IcAgent::Agent.new(iden, client)

    name = agent.query_raw('gvbup-jyaaa-aaaah-qcdwa-cai', 'name', IcAgent::Candid.encode([]))
    expect(name).to include('type' => 'text', 'value' => 'XTC Test')
  end

  it 'IcAgent::Agent call' do
    iden = IcAgent::Identity.new(privkey = '833fe62409237b9d62ec77587520911e9a759cec1d19755b7da901b96dca3d42')
    client = IcAgent::Client.new
    agent = IcAgent::Agent.new(iden, client)

    params = [
      { 'type': IcAgent::Candid::BaseTypes.principal, 'value': 'aaaaa-aa' },
      { 'type': IcAgent::Candid::BaseTypes.nat, 'value': 10000000000 }
    ]

    # req_id = "0899c241fd63ff03345ad164ca5014668d101d6ccafa74730ad9c55c8fbe4942".hex2str
    # paths = [['request_status', req_id]]
    # req = {
    #   'request_type' => 'read_state',
    #   'sender' => iden.sender.bytes,
    #   'paths' => paths,
    #   'ingress_expiry' => 1683366475514657024
    # }
    # req_id = IcAgent::Utils.to_request_id(req)
    # puts req_id
    # puts req_id.to_hex

    result = agent.update_raw('gvbup-jyaaa-aaaah-qcdwa-cai', 'transfer', IcAgent::Candid.encode(params))
  end
end



