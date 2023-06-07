require 'spec_helper'

describe IcAgent::Candid do
  it 'NULL IcAgent::Candid.encode and decode' do
    params = [{ 'type': IcAgent::Candid::BaseTypes.null, 'value': nil }]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql('4449444c00017f')

    decode_params = IcAgent::Candid.decode(data)
    expect(decode_params.size).to eql(1)
    expect(decode_params[0]).to include(
      'type' => 'null',
      'value' => nil
    )
  end

  it 'BOOL IcAgent::Candid.encode and decode' do
    params = [{ 'type': IcAgent::Candid::BaseTypes.bool, 'value': true }]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql('4449444c00017e01')

    decode_params = IcAgent::Candid.decode(data)
    expect(decode_params.size).to eql(1)
    expect(decode_params[0]).to include(
      'type' => 'bool',
      'value' => true
    )
  end

  it 'TEXT IcAgent::Candid.encode' do
    params = [{ 'type': IcAgent::Candid::BaseTypes.text, 'value': 'TEST_STR' }]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql('4449444c00017108544553545f535452')

    decode_params = IcAgent::Candid.decode(data)
    expect(decode_params.size).to eql(1)
    expect(decode_params[0]).to include(
      'type' => 'text',
      'value' => 'TEST_STR'
    )
  end

  it 'Nat IcAgent::Candid.encode' do
    params = [{ 'type': IcAgent::Candid::BaseTypes.nat, 'value': 10 }]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql('4449444c00017d0a')

    decode_params = IcAgent::Candid.decode(data)
    expect(decode_params.size).to eql(1)
    expect(decode_params[0]).to include(
      'type' => 'nat',
      'value' => 10
    )
  end

  it 'Nat32 IcAgent::Candid.encode' do
    params = [{ 'type': IcAgent::Candid::BaseTypes.nat32, 'value': 4294967295 }]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql('4449444c000179ffffffff')

    decode_params = IcAgent::Candid.decode(data)
    expect(decode_params.size).to eql(1)
    expect(decode_params[0]).to include(
      'type' => 'nat32',
      'value' => 4294967295
    )
  end

  it 'Nat64 IcAgent::Candid.encode' do
    params = [{ 'type': IcAgent::Candid::BaseTypes.nat64, 'value': 1000000000000000000 }]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql('4449444c000178000064a7b3b6e00d')

    decode_params = IcAgent::Candid.decode(data)
    expect(decode_params.size).to eql(1)
    expect(decode_params[0]).to include(
      'type' => 'nat64',
      'value' => 1000000000000000000
    )
  end

  it 'Int IcAgent::Candid.encode' do
    params = [{ 'type': IcAgent::Candid::BaseTypes.int, 'value': 10 }]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql('4449444c00017c0a')

    decode_params = IcAgent::Candid.decode(data)
    expect(decode_params.size).to eql(1)
    expect(decode_params[0]).to include(
      'type' => 'int',
      'value' => 10
    )
  end

  it 'Int32 IcAgent::Candid.encode' do
    params = [{ 'type': IcAgent::Candid::BaseTypes.int32, 'value': 2147483647 }]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql('4449444c000175ffffff7f')

    decode_params = IcAgent::Candid.decode(data)
    expect(decode_params.size).to eql(1)
    expect(decode_params[0]).to include(
      'type' => 'int32',
      'value' => 2147483647
    )
  end

  it 'Int64 IcAgent::Candid.encode' do
    params = [{ 'type': IcAgent::Candid::BaseTypes.int64, 'value': 1000000000000000000 }]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql('4449444c000174000064a7b3b6e00d')

    decode_params = IcAgent::Candid.decode(data)
    expect(decode_params.size).to eql(1)
    expect(decode_params[0]).to include(
      'type' => 'int64',
      'value' => 1000000000000000000
    )
  end

  it 'Float32 IcAgent::Candid.encode' do
    params = [{ 'type': IcAgent::Candid::BaseTypes.float32, 'value': 42949672.0 }]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql('4449444c0001730ad7234c')

    decode_params = IcAgent::Candid.decode(data)
    expect(decode_params.size).to eql(1)
    expect(decode_params[0]).to include(
      'type' => 'float32',
      'value' => 42949672.0
    )
  end

  it 'Float64 IcAgent::Candid.encode' do
    params = [{ 'type': IcAgent::Candid::BaseTypes.float64, 'value': 42949672.0 }]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql('4449444c00017200000040e17a8441')

    decode_params = IcAgent::Candid.decode(data)
    expect(decode_params.size).to eql(1)
    expect(decode_params[0]).to include(
      'type' => 'float64',
      'value' => 42949672.0
    )
  end

  it 'Vec(int32) IcAgent::Candid.encode' do
    params = [{ 'type': IcAgent::Candid::BaseTypes.vec(IcAgent::Candid::BaseTypes.int32), 'value': [1, 2, -3] }]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql('4449444c016d750100030100000002000000fdffffff')

    decode_params = IcAgent::Candid.decode(data)
    expect(decode_params.size).to eql(1)
    expect(decode_params[0]).to include(
      'value' => [1, 2, -3]
    )
  end

  it 'Vec(float64) IcAgent::Candid.encode' do
    params = [{ 'type': IcAgent::Candid::BaseTypes.vec(IcAgent::Candid::BaseTypes.float64), 'value': [1.0, 2.0, -3.0] }]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql('4449444c016d72010003000000000000f03f000000000000004000000000000008c0')

    decode_params = IcAgent::Candid.decode(data)
    expect(decode_params.size).to eql(1)
    expect(decode_params[0]).to include(
      'value' => [1.0, 2.0, -3.0]
    )
  end

  it 'Record(float64, float64) IcAgent::Candid.encode' do
    params = [{ 'type': IcAgent::Candid::BaseTypes.record({ 'key1' => IcAgent::Candid::BaseTypes.float64, 'key2' => IcAgent::Candid::BaseTypes.float64 }), 'value': { 'key1' => 1.0, 'key2' => 2.0 } }]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql('4449444c016c02b2c39bb80472b3c39bb804720100000000000000f03f0000000000000040')

    decode_params = IcAgent::Candid.decode(data)
    expect(decode_params.size).to eql(1)
    expect(decode_params[0]).to include(
      'value' => { '_1191633330_'=>1.0, '_1191633331_'=>2.0 }
    )
  end

  it 'Record(float64, float64) IcAgent::Candid.encode' do
    params = [{ 'type': IcAgent::Candid::BaseTypes.record({ 'key3' => IcAgent::Candid::BaseTypes.float64, 'key4' => IcAgent::Candid::BaseTypes.float64 }), 'value': { 'key3' => 1.0, 'key4' => 2.0 } }]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql('4449444c016c02b4c39bb80472b5c39bb804720100000000000000f03f0000000000000040')

    decode_params = IcAgent::Candid.decode(data)
    expect(decode_params.size).to eql(1)
    expect(decode_params[0]).to include(
      'value' => { '_1191633332_'=>1.0, '_1191633333_'=>2.0 }
    )
  end

  it 'Record(int, int64) IcAgent::Candid.encode' do
    params = [{ 'type': IcAgent::Candid::BaseTypes.record({ 'key1' => IcAgent::Candid::BaseTypes.int, 'key2' => IcAgent::Candid::BaseTypes.int64 }), 'value': { 'key1' => 1, 'key2' => 2 } }]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql('4449444c016c02b2c39bb8047cb3c39bb804740100010200000000000000')

    decode_params = IcAgent::Candid.decode(data)
    expect(decode_params.size).to eql(1)
    expect(decode_params[0]).to include(
      'value' => { '_1191633330_'=>1, '_1191633331_'=>2 }
    )
  end

  it 'Record(int, int64, Record(int, int64)) IcAgent::Candid.encode' do
    params = [{ 'type': IcAgent::Candid::BaseTypes.record({ 'key1' => IcAgent::Candid::BaseTypes.int, 'key2' => IcAgent::Candid::BaseTypes.int64, 'key3' => IcAgent::Candid::BaseTypes.record({ 'key1' => IcAgent::Candid::BaseTypes.int, 'key2' => IcAgent::Candid::BaseTypes.int64}) }), 'value': { 'key1' => 1, 'key2' => 2, 'key3' => { 'key1' => 1, 'key2' => 2 } } }]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql('4449444c026c02b2c39bb8047cb3c39bb804746c03b2c39bb8047cb3c39bb80474b4c39bb804000101010200000000000000010200000000000000')

    decode_params = IcAgent::Candid.decode(data)
    expect(decode_params.size).to eql(1)
    expect(decode_params[0]).to include(
      'value' => {"_1191633330_"=>1, "_1191633331_"=>2, "_1191633332_"=>{"_1191633330_"=>1, "_1191633331_"=>2}}
    )
  end

  it 'Principal(aaaaa-aa) IcAgent::Candid.encode' do
    params = [{ 'type': IcAgent::Candid::BaseTypes.principal, 'value': 'aaaaa-aa' }]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql('4449444c0001680100')

    decode_params = IcAgent::Candid.decode(data)
    expect(decode_params.size).to eql(1)
    expect(decode_params[0]).to include(
      'type' => 'principal',
      'value' => 'aaaaa-aa'
    )
  end

  it 'Principal(h4shw-tywvx-l2ql2-mzsjh-ym5d3-5r65b-zogwd-atf22-43k44-jnv4c-wae) IcAgent::Candid.encode' do
    params = [{ 'type': IcAgent::Candid::BaseTypes.principal, 'value': 'h4shw-tywvx-l2ql2-mzsjh-ym5d3-5r65b-zogwd-atf22-43k44-jnv4c-wae' }]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql('4449444c000168011d16add7a82f4ccc927c33a3df63ee872e358609975ae6d5ce25b5e0ac02')

    decode_params = IcAgent::Candid.decode(data)
    expect(decode_params.size).to eql(1)
    expect(decode_params[0]).to include(
      'type' => 'principal',
      'value' => 'h4shw-tywvx-l2ql2-mzsjh-ym5d3-5r65b-zogwd-atf22-43k44-jnv4c-wae'
    )
  end

  it 'Opt(int) IcAgent::Candid.encode' do
    params = [{ 'type': IcAgent::Candid::BaseTypes.opt(IcAgent::Candid::BaseTypes.int), 'value': [1] }]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql('4449444c016e7c01000101')

    decode_params = IcAgent::Candid.decode(data)
    expect(decode_params.size).to eql(1)
    expect(decode_params[0]).to include(
      'value' => [1]
    )
  end

  it 'Opt(float64) IcAgent::Candid.encode' do
    params = [{ 'type': IcAgent::Candid::BaseTypes.opt(IcAgent::Candid::BaseTypes.float64), 'value': [456.123] }]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql('4449444c016e720100018716d9cef7817c40')

    decode_params = IcAgent::Candid.decode(data)
    expect(decode_params.size).to eql(1)
    expect(decode_params[0]).to include(
      'value' => [456.123]
    )
  end

  it 'Variant(ok, err) IcAgent::Candid.encode' do
    params = [{ 'type': IcAgent::Candid::BaseTypes.variant({ 'ok' => IcAgent::Candid::BaseTypes.text, 'err' => IcAgent::Candid::BaseTypes.text }), 'value': { 'ok' => 'succ' } }]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql('4449444c016b029cc20171e58eb402710100000473756363')

    decode_params = IcAgent::Candid.decode(data)
    expect(decode_params.size).to eql(1)
    expect(decode_params[0]).to include(
      'value' => { '_24860_'=>'succ' }
    )
  end

  it 'Variant(ok, err) IcAgent::Candid.encode' do
    params = [{ 'type': IcAgent::Candid::BaseTypes.variant({ 'ok' => IcAgent::Candid::BaseTypes.text, 'err' => IcAgent::Candid::BaseTypes.text }), 'value': { 'err' => 'fail' } }]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql('4449444c016b029cc20171e58eb40271010001046661696c')

    decode_params = IcAgent::Candid.decode(data)
    expect(decode_params.size).to eql(1)
    expect(decode_params[0]).to include(
      'value' => { '_5048165_'=>'fail' }
    )
  end

  it 'Tuple(nat, text) IcAgent::Candid.encode' do
    params = [{ 'type': IcAgent::Candid::BaseTypes.tuple(IcAgent::Candid::BaseTypes.nat, IcAgent::Candid::BaseTypes.text), 'value': [123456, 'terry.tu'] }]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql('4449444c016c02007d01710100c0c4070874657272792e7475')

    decode_params = IcAgent::Candid.decode(data)
    expect(decode_params.size).to eql(1)
    expect(decode_params[0]).to include(
      'value' => [123456, 'terry.tu']
    )
  end

  it 'Func IcAgent::Candid.encode' do
    params = [{ 'type': IcAgent::Candid::BaseTypes.func([IcAgent::Candid::BaseTypes.text], [IcAgent::Candid::BaseTypes.nat], ['query']), 'value': ['expmt-gtxsw-inftj-ttabj-qhp5s-nozup-n3bbo-k7zvn-dg4he-knac3-lae', 'terry'] }]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql('4449444c016a0171017d0101010001011d779590d2cd339802981dfd935d9a3dbb085cafe6ad19b87229a016d602057465727279')

    decode_params = IcAgent::Candid.decode(data)
    expect(decode_params.size).to eql(1)
    expect(decode_params[0]).to include(
      'value' => ['expmt-gtxsw-inftj-ttabj-qhp5s-nozup-n3bbo-k7zvn-dg4he-knac3-lae', 'terry']
    )
  end

  it 'Service IcAgent::Candid.encode' do
    params = [{ 'type': IcAgent::Candid::BaseTypes.service({ 'query_service': IcAgent::Candid::BaseTypes.func([IcAgent::Candid::BaseTypes.text], [IcAgent::Candid::BaseTypes.nat], ['query']) }), 'value': 'expmt-gtxsw-inftj-ttabj-qhp5s-nozup-n3bbo-k7zvn-dg4he-knac3-lae' }]
    data = IcAgent::Candid.encode(params)
    expect(data).to eql('4449444c026a0171017d010169010d71756572795f73657276696365000101011d779590d2cd339802981dfd935d9a3dbb085cafe6ad19b87229a016d602')

    decode_params = IcAgent::Candid.decode(data)
    expect(decode_params.size).to eql(1)
    expect(decode_params[0]).to include(
      'value' => 'expmt-gtxsw-inftj-ttabj-qhp5s-nozup-n3bbo-k7zvn-dg4he-knac3-lae'
    )
  end
end