require 'spec_helper'
require 'byebug'

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
    result = agent.update_raw('gvbup-jyaaa-aaaah-qcdwa-cai', 'transfer', IcAgent::Candid.encode(params))

    expect(result.size).to eql(1)
    expect(result[0]).to include('type' => 'rec_0')
  end

  it 'IcAgent::Agent read_state_raw and bls verify certificate' do
    iden = IcAgent::Identity.new
    client = IcAgent::Client.new
    agent = IcAgent::Agent.new(iden, client)
    canister_id = 'gvbup-jyaaa-aaaah-qcdwa-cai'

    cert = agent.read_state_raw(canister_id, [['time']])
    verify = agent.verify(cert, canister_id)
    expect(verify).to eql(true)
  end
end



