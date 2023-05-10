require_relative 'principal'
require_relative 'certificate'
require 'leb128'
require 'cbor'

module IcAgent
  class SyetemState
    def self.time(agent, canister_id)
      cert = agent.read_state_raw(canister_id, [['time']])
      timestamp = Certificate.lookup(['time'], cert)
      str_io = StringIO.new(timestamp)
      LEB128.decode_signed(str_io)
    end

    def self.subnet_public_key(agent, canister_id, subnet_id)
      path = ['subnet', Principal.from_str(subnet_id).bytes, 'public_key']
      cert = agent.read_state_raw(canister_id, [path])
      pubkey = Certificate.lookup(path, cert)
      pubkey.str2hex
    end

    def self.subnet_canister_ranges(agent, canister_id, subnet_id)
      path = ['subnet', Principal.from_str(subnet_id).bytes, 'canister_ranges']
      cert = agent.read_state_raw(canister_id, [path])
      ranges = Certificate.lookup(path, cert)
      CBOR.decode(ranges).value.map { |range| range.map { |item| Principal.new(bytes: item) } }
    end

    def self.canister_module_hash(agent, canister_id)
      path = ['canister', Principal.from_str(canister_id).bytes, 'module_hash']
      cert = agent.read_state_raw(canister_id, [path])
      module_hash = Certificate.lookup(path, cert)
      module_hash.str2hex
    end

    def self.canister_controllers(agent, canister_id)
      path = ['canister', Principal.from_str(canister_id).bytes, 'controllers']
      cert = agent.read_state_raw(canister_id, [path])
      controllers = Certificate.lookup(path, cert)
      CBOR.decode(controllers).map { |item| Principal.new(bytes: item) }
    end
  end
end
