require 'spec_helper'

describe IcAgent::Candid do
  it "Nat IcAgent::Candid.encode" do
    params = [{'type': IcAgent::Candid::BaseTypes.nat, 'value': 10}]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql("4449444c00017d0a")
  end

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
end