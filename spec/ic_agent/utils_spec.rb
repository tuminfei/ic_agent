require 'spec_helper'

describe IcAgent::Utils do
  it 'to_request_id' do
    iden = IcAgent::Identity.new(privkey = '833fe62409237b9d62ec77587520911e9a759cec1d19755b7da901b96dca3d42')

    req_id = "0899c241fd63ff03345ad164ca5014668d101d6ccafa74730ad9c55c8fbe4942".hex2str
    paths = [['request_status', req_id]]
    req = {
      'request_type' => 'read_state',
      'sender' => iden.sender.bytes,
      'paths' => paths,
      'ingress_expiry' => 1683366475514657024
    }
    req_id = IcAgent::Utils.to_request_id(req)
    expect(req_id.to_hex).to eql('581d37509518dc5664c23bce1af3657ed231f1074973d02bc95123176d3aede2')
  end
end