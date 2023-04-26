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

  it "Int IcAgent::Candid.encode" do
    params = [{'type': IcAgent::Candid::BaseTypes.int, 'value': 10}]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql("4449444c00017c0a")
  end

  it "Int32 IcAgent::Candid.encode" do
    params = [{'type': IcAgent::Candid::BaseTypes.int32, 'value': 2147483647}]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql("4449444c000175ffffff7f")
  end

  it "Int64 IcAgent::Candid.encode" do
    params = [{'type': IcAgent::Candid::BaseTypes.int64, 'value': 1000000000000000000}]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql("4449444c000174000064a7b3b6e00d")
  end

  it "Float32 IcAgent::Candid.encode" do
    params = [{'type': IcAgent::Candid::BaseTypes.float32, 'value': 42949672.0}]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql("4449444c0001730ad7234c")
  end

  it "Float64 IcAgent::Candid.encode" do
    params = [{'type': IcAgent::Candid::BaseTypes.float64, 'value': 42949672.0}]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql("4449444c00017200000040e17a8441")
  end

  it "Vec(int32) IcAgent::Candid.encode" do
    params = [{'type': IcAgent::Candid::BaseTypes.vec(IcAgent::Candid::BaseTypes.int32), 'value': [1, 2, -3]}]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql("4449444c016d750100030100000002000000fdffffff")
  end

  it "Vec(int32) IcAgent::Candid.encode" do
    params = [{'type': IcAgent::Candid::BaseTypes.vec(IcAgent::Candid::BaseTypes.float64), 'value': [1.0, 2.0, -3.0]}]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql("4449444c016d72010003000000000000f03f000000000000004000000000000008c0")
  end

  it "Record(float64, float64) IcAgent::Candid.encode" do
    params = [{'type': IcAgent::Candid::BaseTypes.record({"key1" => IcAgent::Candid::BaseTypes.float64, "key2" => IcAgent::Candid::BaseTypes.float64}), 'value': {"key1" => 1.0, "key2" => 2.0}}]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql("4449444c016c02b2c39bb80472b3c39bb804720100000000000000f03f0000000000000040")
  end

  it "Record(float64, float64) IcAgent::Candid.encode" do
    params = [{'type': IcAgent::Candid::BaseTypes.record({"key1" => IcAgent::Candid::BaseTypes.int, "key2" => IcAgent::Candid::BaseTypes.int64}), 'value': {"key1" => 1, "key2" => 2}}]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql("4449444c016c02b2c39bb8047cb3c39bb804740100010200000000000000")
  end

  it "Principal(aaaaa-aa) IcAgent::Candid.encode" do
    params = [{'type': IcAgent::Candid::BaseTypes.principal, 'value': "aaaaa-aa"}]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql("4449444c0001680100")
  end

  it "Principal(h4shw-tywvx-l2ql2-mzsjh-ym5d3-5r65b-zogwd-atf22-43k44-jnv4c-wae) IcAgent::Candid.encode" do
    params = [{'type': IcAgent::Candid::BaseTypes.principal, 'value': "h4shw-tywvx-l2ql2-mzsjh-ym5d3-5r65b-zogwd-atf22-43k44-jnv4c-wae"}]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql("4449444c000168011d16add7a82f4ccc927c33a3df63ee872e358609975ae6d5ce25b5e0ac02")
  end

  it "Opt(int) IcAgent::Candid.encode" do
    params = [{'type': IcAgent::Candid::BaseTypes.opt(IcAgent::Candid::BaseTypes.int), 'value': [1]}]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql("4449444c016e7c01000101")
  end

  it "Opt(float64) IcAgent::Candid.encode" do
    params = [{'type': IcAgent::Candid::BaseTypes.opt(IcAgent::Candid::BaseTypes.float64), 'value': [456.123]}]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql("4449444c016e720100018716d9cef7817c40")
  end

  it "Variant(ok, err) IcAgent::Candid.encode" do
    params = [{'type': IcAgent::Candid::BaseTypes.variant({"ok" => IcAgent::Candid::BaseTypes.text, "err" => IcAgent::Candid::BaseTypes.text}), 'value': {"ok" => "succ"}}]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql("4449444c016b029cc20171e58eb402710100000473756363")
  end

  it "Variant(ok, err) IcAgent::Candid.encode" do
    params = [{'type': IcAgent::Candid::BaseTypes.variant({"ok" => IcAgent::Candid::BaseTypes.text, "err" => IcAgent::Candid::BaseTypes.text}), 'value': {"err" => "fail"}}]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql("4449444c016b029cc20171e58eb40271010001046661696c")
  end
end