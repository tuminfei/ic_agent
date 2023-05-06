require 'spec_helper'

describe IcAgent::Identity do
  it "ed25519 IcAgent::Identity" do
    iden = IcAgent::Identity.new(privkey = '833fe62409237b9d62ec77587520911e9a759cec1d19755b7da901b96dca3d42')
    expect(iden.key_type).to eql('ed25519')
    expect(iden.pubkey).to eql('ec172b93ad5e563bf4932c70e1245034c35467ef2efd4d64ebf819683467e2bf')
    expect(iden.sender.to_s).to eql('7aodp-4ebhh-pj5sa-5kdmg-fkkw3-wk6rv-yf4rr-pt2g7-ebx7j-7sjq4-4qe')
  end
end