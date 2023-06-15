require 'spec_helper'
require 'byebug'

describe IcAgent::Common::Management do
  before(:all) do
    @management = IcAgent::Common::Management.new
  end

  it 'IcAgent::Common::Management name call' do
    query = {
      'canister_id' => 'xizxk-fqaaa-aaaap-aa2nq-cai'
    }
    status = @management.canister.canister_status(query)
    expect(status[0]).to include('_1224700491_' => 'Internet Computer')
  end
end



