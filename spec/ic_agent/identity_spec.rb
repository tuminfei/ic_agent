require 'spec_helper'

describe IcAgent::Identity do
  it "ed25519 IcAgent::Identity" do
    iden = IcAgent::Identity.new(privkey = '833fe62409237b9d62ec77587520911e9a759cec1d19755b7da901b96dca3d42')
    expect(iden.key_type).to eql('ed25519')
    expect(iden.pubkey).to eql('ec172b93ad5e563bf4932c70e1245034c35467ef2efd4d64ebf819683467e2bf')
    expect(iden.sender.to_s).to eql('7aodp-4ebhh-pj5sa-5kdmg-fkkw3-wk6rv-yf4rr-pt2g7-ebx7j-7sjq4-4qe')
  end

  it "secp256k1 IcAgent::Identity" do
    iden = IcAgent::Identity.new(privkey = '833fe62409237b9d62ec77587520911e9a759cec1d19755b7da901b96dca3d42', type = 'secp256k1')
    expect(iden.key_type).to eql('secp256k1')
    expect(iden.pubkey).to eql('048e24fd9654f12c793d3d376c15f7abe53e0fbd537884a3a98d10d2dc6d513b4e08dd453b73d6e06f5c543a4b6d0e9fa7cff4ffde6897ff64a1afd787d2b6f87c')
    expect(iden.sender.to_s).to eql('ogeza-v2sup-7el77-mls7v-kjxbs-tzekc-gywh3-dzikt-qisuu-xsc46-mqe')
  end

  it "mnemonic IcAgent::Identity" do
    mnemonic = 'fence dragon soft spoon embrace bronze regular hawk more remind detect slam'
    iden = IcAgent::Identity.from_seed(mnemonic)
    expect(iden.key_type).to eql('ed25519')
    expect(iden.privkey).to eql('97cc884647e7e0ef58c36b57448269ba6a123521a7f234fa5fdc5816d824ef50')
  end
end