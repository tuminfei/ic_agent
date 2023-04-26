require 'spec_helper'

describe IcAgent::Candid do
  it "NULL IcAgent::Candid.encode" do
    params = [{'type': IcAgent::Candid::BaseTypes.null, 'value': nil}]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql("4449444c00017f")
  end

  it "BOOL IcAgent::Candid.encode" do
    params = [{'type': IcAgent::Candid::BaseTypes.bool, 'value': true}]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql("4449444c00017e01")
  end

  it "BOOL IcAgent::Candid.encode" do
    params = [{'type': IcAgent::Candid::BaseTypes.text, 'value': "TEST_STR"}]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql("4449444c00017108544553545f535452")
  end

  it "BOOL IcAgent::Candid.encode" do
    params = [{'type': IcAgent::Candid::BaseTypes.text, 'value': "TEST_STR"}]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql("4449444c00017108544553545f535452")
  end

  it "Nat IcAgent::Candid.encode" do
    params = [{'type': IcAgent::Candid::BaseTypes.nat, 'value': 10}]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql("4449444c00017d0a")
  end

  it "Nat32 IcAgent::Candid.encode" do
    params = [{'type': IcAgent::Candid::BaseTypes.nat32, 'value': 4294967295}]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql("4449444c000179ffffffff")
  end

  it "Nat64 IcAgent::Candid.encode" do
    params = [{'type': IcAgent::Candid::BaseTypes.nat64, 'value': 1000000000000000000}]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql("4449444c000178000064a7b3b6e00d")
  end
end