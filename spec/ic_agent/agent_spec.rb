require 'spec_helper'

describe IcAgent::Agent do
  it "IcAgent::Agent call" do
    iden = IcAgent::Identity.new(privkey = "833fe62409237b9d62ec77587520911e9a759cec1d19755b7da901b96dca3d42")
    client = IcAgent::Client.new
    agent = IcAgent::Agent.new(iden, client)

    name = agent.query_raw("gvbup-jyaaa-aaaah-qcdwa-cai", "name", IcAgent::Candid.encode([]))
    expect(name).to include('type' => 'text', 'value' => 'XTC Test')
  end
end