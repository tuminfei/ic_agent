require 'spec_helper'

describe IcAgent::Common::CyclesWallet do
  before(:all) do
    @cycles_wallet = IcAgent::Common::CyclesWallet.new(nil, 'aanaa-xaaaa-aaaah-aaeiq-cai')
  end

  it 'IcAgent::Common::CyclesWallet name call' do
    name = @cycles_wallet.canister.name
    expect(name[0]).to eq('Cycles')
  end

  it 'IcAgent::Common::CyclesWallet symbol call' do
    symbol = @cycles_wallet.canister.symbol
    expect(symbol[0]).to eq('XTC')
  end
end
