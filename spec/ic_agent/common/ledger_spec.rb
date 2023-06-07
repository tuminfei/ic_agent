require 'spec_helper'

describe IcAgent::Common::Ledger do
  before(:all) do
    @ledger = IcAgent::Common::Ledger.new
  end

  it 'IcAgent::Common::Ledger name call' do
    name = @ledger.canister.name
    expect(name[0]).to include('_1224700491_' => 'Internet Computer')
  end

  it 'IcAgent::Common::Ledger symbol call' do
    symbol = @ledger.canister.symbol
    expect(symbol[0]).to include('_4007505752_' => 'ICP')
  end
end



