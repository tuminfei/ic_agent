require 'spec_helper'

describe IcAgent::Agent do
  it "IcAgent::Agent call" do
    iden = IcAgent::Identity.new
    client = IcAgent::Client.new
    agent = IcAgent::Agent.new(iden, client)

    name = agent.query_raw("gvbup-jyaaa-aaaah-qcdwa-cai", "name", IcAgent::Candid.encode([]))
  end
end