require_relative 'ic_agent/principal'
require 'leb128'
require 'cbor'

module IcAgent
  class SyetemState
    def time(agent, canister_id)
      cert = agent.read_state_raw(canister_id, [['time']])
      timestamp = lookup(['time'], cert)
      LEB128.encode_signed(timestamp.bytes)
    end

    def subnet_public_key(agent, canister_id, subnet_id)
      path = ['subnet', Principal.from_str(subnet_id).bytes, 'public_key']
      cert = agent.read_state_raw(canister_id, [path])
      pubkey = lookup(path, cert)
      pubkey.unpack1('H*')
    end

    def subnet_canister_ranges(agent, canister_id, subnet_id)
      path = ['subnet', Principal.from_str(subnet_id).bytes, 'canister_ranges']
      cert = agent.read_state_raw(canister_id, [path])
      ranges = lookup(path, cert)
      CBOR.decode(ranges).map { |range| range.map { |item| Principal.new(bytes: item) } }
    end

    def canister_module_hash(agent, canister_id)
      path = ['canister', Principal.from_str(canister_id).bytes, 'module_hash']
      cert = agent.read_state_raw(canister_id, [path])
      module_hash = lookup(path, cert)
      module_hash.unpack1('H*')
    end

    def canister_controllers(agent, canister_id)
      path = ['canister', Principal.from_str(canister_id).bytes, 'controllers']
      cert = agent.read_state_raw(canister_id, [path])
      controllers = lookup(path, cert)
      CBOR.decode(controllers).map { |item| Principal.new(bytes: item) }
    end
  end
end
