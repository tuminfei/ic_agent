require 'cbor'
require 'ctf_party'


module IcAgent
  class Request
    def self.sign_request(req, iden)
      req_id = IcAgent::Utils.to_request_id(req)
      msg = IcAgent::IC_REQUEST_DOMAIN_SEPARATOR + req_id
      sig = iden.sign(msg)
      envelop = {
        'content': req,
        'sender_pubkey': sig[0],
        'sender_sig': sig[1]
      }

      if iden.is_a?(DelegateIdentity)
        envelop.update({
                         'sender_pubkey': iden.der_pubkey,
                         'sender_delegation': iden.delegations
                       })
      end
      [req_id, CBOR.encode(envelop)]
    end
  end

  class Agent
    attr_accessor :identity, :client, :ingress_expiry, :root_key, :nonce_factory

    def initialize(identity, client, nonce_factory = nil, ingress_expiry = 300, root_key = IcAgent::IC_ROOT_KEY)
      @identity = identity
      @client = client
      @ingress_expiry = ingress_expiry
      @root_key = root_key
      @nonce_factory = nonce_factory
    end

    def get_principal
      @identity.sender
    end

    def get_expiry_date
      ((Time.now.to_i + @ingress_expiry) * 10**9).to_i
    end

    def query_endpoint(canister_id, data)
      ret = @client.query(canister_id, data)
      decode_ret = nil
      begin
        decode_ret = CBOR.decode(ret)
      rescue CBOR::MalformedFormatError
        decode_ret = ret
        # print logger
      end
      decode_ret
    end

    def call_endpoint(canister_id, request_id, data)
      @client.call(canister_id, request_id, data)
      request_id
    end

    def read_state_endpoint(canister_id, data)
      result = @client.read_state(canister_id, data)
      result
    end

    def query_raw(canister_id, method_name, arg, return_type = nil, effective_canister_id = nil)
      req_canister_id = canister_id.is_a?(String) ? Principal.from_str(canister_id).bytes : canister_id.bytes
      req = {
        'request_type' => 'query',
        'sender' => @identity.sender.bytes,
        'canister_id' => req_canister_id,
        'method_name' => method_name,
        'arg' => arg.hex2str,
        'ingress_expiry' => get_expiry_date
      }

      _, data = Request.sign_request(req, @identity)
      query_canister_id = effective_canister_id.nil? ? canister_id : effective_canister_id
      result = query_endpoint(query_canister_id, data)
      raise Exception, "Malformed result: #{result}" unless result.is_a?(CBOR::Tagged) && result.value.key?('status')

      if result.value['status'] == 'replied'
        arg = result.value['reply']['arg']
        if arg[0..3] == 'DIDL'
          IcAgent::Candid.decode(arg.to_hex, return_type)
        else
          arg
        end
      elsif result.value['status'] == 'rejected'
        raise Exception, "Canister reject the call: #{result['reject_message']}"
      end
    end

    def update_raw(canister_id, method_name, arg, return_type = nil, effective_canister_id = nil, **kwargs)
      req_canister_id = canister_id.is_a?(String) ? Principal.from_str(canister_id).bytes : canister_id.bytes
      req = {
        'request_type' => 'call',
        'sender' => @identity.sender.bytes,
        'canister_id' => req_canister_id,
        'method_name' => method_name,
        'arg' => arg.hex2str,
        'ingress_expiry' => get_expiry_date
      }
      req_id, data = Request.sign_request(req, @identity)
      eid = effective_canister_id.nil? ? canister_id : effective_canister_id
      _ = call_endpoint(eid, req_id, data)
      status, result = poll(eid, req_id, **kwargs)
      if status == 'rejected'
        raise Exception, "Rejected: #{result.to_s}"
      elsif status == 'replied'
        if result[0..3] == 'DIDL'
          IcAgent::Candid.decode(result, return_type)
        else
          # Some canisters don't use DIDL (e.g. they might encode using json instead)
          result
        end
      else
        raise Exception, "Timeout to poll result, current status: #{status.to_s}"
      end
    end

    def read_state_raw(canister_id, paths)
      req = {
        'request_type' => 'read_state',
        'sender' => @identity.sender.bytes,
        'paths' => paths,
        'ingress_expiry' => get_expiry_date
      }
      _, data = Request.sign_request(req, @identity)
      ret = read_state_endpoint(canister_id, data)
      if ret == 'Invalid path requested.'
        raise ValueError, 'Invalid path requested!'
      elsif ret == 'Could not parse body as read request: invalid type: byte array, expected a sequence'
        raise ValueError, 'Could not parse body as read request: invalid type: byte array, expected a sequence'
      end

      begin
        d = CBOR.decode(ret)
      rescue StandardError
        raise ValueError, "Unable to decode cbor value: #{ret}"
      end
      CBOR.decode(d.value['certificate'])
    end

    def request_status_raw(canister_id, req_id)
      paths = [['request_status', req_id]]
      cert = read_state_raw(canister_id, paths)
      status = IcAgent::Certificate.lookup(['request_status', req_id, 'status'], cert)
      if status.nil?
        [status, cert]
      else
        [status.decode, cert]
      end
    end

    def poll(canister_id, req_id, delay = 1, timeout = IcAgent::DEFAULT_POLL_TIMEOUT_SECS)
      status = nil
      (timeout / delay).to_i.times do
        status, cert = request_status_raw(canister_id, req_id)
        break if %w[replied done rejected].include?(status)

        sleep(delay)
      end

      if status == 'replied'
        path = ['request_status', req_id, 'reply']
        res = IcAgent::Certificate.lookup(path, cert)
        [status, res]
      elsif status == 'rejected'
        path = ['request_status', req_id, 'reject_message']
        msg = IcAgent::Certificate.lookup(path, cert)
        [status, msg]
      else
        [status, _]
      end
    end
  end
end
