require 'spec_helper'
require 'byebug'

describe IcAgent::Common::Management do
  before(:all) do
    @management = IcAgent::Common::Management.new
  end

  it 'IcAgent::Common::Management name call' do
    query = {
      'canister_id' => 'zri47-daaaa-aaaah-adjzq-cai',
      'num_requested_changes' => [0]
    }
    status = @management.canister.canister_info(query)
  end
end



