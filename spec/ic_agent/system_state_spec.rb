require 'spec_helper'

describe IcAgent::SyetemState do

  before(:all) do
    iden = IcAgent::Identity.new
    client = IcAgent::Client.new
    @agent = IcAgent::Agent.new(iden, client)
    @subnet_key = '308182301d060d2b0601040182dc7c0503010201060c2b0601040182dc7c05030201036100b31b406c9f6648695a88154ae2e4f5fe87883d4ad81c2844c5571b2d91d401cdd40836e763a7c18dccb84629b0d808f7142c3175bc8231dc09bd53637efd6f2568801385ec973d34e6eef9c8c8280a9f4a114163a43a8540941ba367f0c7cb28'
  end


  it 'IcAgent::SyetemState time call' do
    time = IcAgent::SyetemState.time(@agent, "gvbup-jyaaa-aaaah-qcdwa-cai")
    t = Time.now.to_i.to_s[0..7]
    expect(time.to_s).to start_with t
  end

  it 'IcAgent::SyetemState subnet_public_key call' do
    subnet_public_key = IcAgent::SyetemState.subnet_public_key(@agent, "gvbup-jyaaa-aaaah-qcdwa-cai", "pjljw-kztyl-46ud4-ofrj6-nzkhm-3n4nt-wi3jt-ypmav-ijqkt-gjf66-uae")
    expect(subnet_public_key).to eql(@subnet_key)
  end

  it 'IcAgent::SyetemState subnet_canister_ranges call' do
    subnet_canister_ranges = IcAgent::SyetemState.subnet_canister_ranges(@agent, "gvbup-jyaaa-aaaah-qcdwa-cai", "pjljw-kztyl-46ud4-ofrj6-nzkhm-3n4nt-wi3jt-ypmav-ijqkt-gjf66-uae")
    expect(subnet_canister_ranges[0].size).to eql(2)
    expect(subnet_canister_ranges[0][0].to_s).to eql("ywrdt-7aaaa-aaaah-qaaaa-cai")
    expect(subnet_canister_ranges[0][1].to_s).to eql("e5xzy-miaaa-aaaah-7777q-cai")
  end

  it 'IcAgent::SyetemState canister_module_hash call' do
    canister_module_hash = IcAgent::SyetemState.canister_module_hash(@agent, "gvbup-jyaaa-aaaah-qcdwa-cai")
    expect(canister_module_hash).to eql("eb2dc31abb598a84877e00eec83c305eea1c98108550b3d7e7be8ec7bc84b045")
  end

  it 'IcAgent::SyetemState canister_controllers call' do
    canister_controllers = IcAgent::SyetemState.canister_controllers(@agent, "sxhuu-qqaaa-aaaai-qbbcq-cai")
    expect(canister_controllers[0].to_s).to eql("sqgsa-5iaaa-aaaai-qbbca-cai")
  end
end



