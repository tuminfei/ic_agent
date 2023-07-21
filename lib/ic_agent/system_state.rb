require_relative 'principal'
require_relative 'certificate'
require 'leb128'
require 'cbor'

module IcAgent
  class SyetemState
    # Retrieves the system time from a canister's state.
    #
    # Parameters:
    # - agent: The IcAgent::Client instance.
    # - canister_id: The ID of the canister.
    #
    # Returns: The system time as a timestamp.
    def self.time(agent, canister_id)
      cert = agent.read_state_raw(canister_id, [['time']])
      timestamp = Certificate.lookup(['time'], cert)
      str_io = StringIO.new(timestamp)
      LEB128.decode_signed(str_io)
    end

    # Retrieves the public key of a subnet from a canister's state.
    #
    # Parameters:
    # - agent: The IcAgent::Client instance.
    # - canister_id: The ID of the canister.
    # - subnet_id: The ID of the subnet.
    #
    # Returns: The public key of the subnet in hexadecimal format.
    def self.subnet_public_key(agent, canister_id, subnet_id)
      path = ['subnet', Principal.from_str(subnet_id).bytes, 'public_key']
      cert = agent.read_state_raw(canister_id, [path])
      pubkey = Certificate.lookup(path, cert)
      pubkey.str2hex
    end

    # Retrieves the canister ranges of a subnet from a canister's state.
    #
    # Parameters:
    # - agent: The IcAgent::Client instance.
    # - canister_id: The ID of the canister.
    # - subnet_id: The ID of the subnet.
    #
    # Returns: An array of canister ranges, where each range is represented as an array of Principal instances.
    def self.subnet_canister_ranges(agent, canister_id, subnet_id)
      path = ['subnet', Principal.from_str(subnet_id).bytes, 'canister_ranges']
      cert = agent.read_state_raw(canister_id, [path])
      ranges = Certificate.lookup(path, cert)
      CBOR.decode(ranges).value.map { |range| range.map { |item| Principal.new(bytes: item) } }
    end

    # Retrieves the module hash of a canister from a canister's state.
    #
    # Parameters:
    # - agent: The IcAgent::Client instance.
    # - canister_id: The ID of the canister.
    #
    # Returns: The module hash of the canister in hexadecimal format.
    def self.canister_module_hash(agent, canister_id)
      path = ['canister', Principal.from_str(canister_id).bytes, 'module_hash']
      cert = agent.read_state_raw(canister_id, [path])
      module_hash = Certificate.lookup(path, cert)
      module_hash.str2hex
    end

    # Retrieves the controllers of a canister from a canister's state.
    #
    # Parameters:
    # - agent: The IcAgent::Client instance.
    # - canister_id: The ID of the canister.
    #
    # Returns: An array of Principal instances representing the controllers of the canister.
    def self.canister_controllers(agent, canister_id)
      path = ['canister', Principal.from_str(canister_id).bytes, 'controllers']
      cert = agent.read_state_raw(canister_id, [path])
      controllers = Certificate.lookup(path, cert)
      CBOR.decode(controllers).value.map { |item| Principal.new(bytes: item) }
    end
  end
end
