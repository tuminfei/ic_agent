require 'cbor'
require 'bls'
require 'ctf_party'
require 'bitcoin'

module IcAgent
  class Request
    # Signs a request with an identity's signature and encodes it using CBOR.
    #
    # @param req [Hash] The request to be signed.
    # @param iden [Identity] The identity used for signing.
    # @return [Array] The request ID and the encoded signed request.
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

    # Initializes a new IC agent.
    #
    # @param identity [Identity] The identity associated with the agent.
    # @param client [Client] The client used for communication with the IC network.
    # @param nonce_factory [NonceFactory] The factory for generating nonces.
    # @param ingress_expiry [Integer] The expiration time for ingress requests.
    # @param root_key [String] The IC root key used for verification.
    def initialize(identity, client, nonce_factory = nil, ingress_expiry = 300, root_key = IcAgent::IC_ROOT_KEY)
      @identity = identity
      @client = client
      @ingress_expiry = ingress_expiry
      @root_key = root_key
      @nonce_factory = nonce_factory
    end

    # Retrieves the principal associated with the agent's identity.
    #
    # @return [Principal] The principal associated with the agent.
    def get_principal
      @identity.sender
    end

    # Calculates the expiration date for ingress requests.
    #
    # @return [Integer] The expiration date in nanoseconds.
    def get_expiry_date
      ((Time.now.to_i + @ingress_expiry) * 10**9).to_i
    end

    # Sends a query request to a canister and decodes the response using CBOR.
    #
    # @param canister_id [String] The ID of the target canister.
    # @param data [Hash] The data to be sent in the query request.
    # @return [Object] The decoded response from the canister.
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

    # Calls a method on a canister and returns the request ID.
    #
    # @param canister_id [String] The ID of the target canister.
    # @param request_id [String] The ID of the request.
    # @param data [Hash] The data to be sent in the call request.
    # @return [String] The request ID.
    def call_endpoint(canister_id, request_id, data)
      @client.call(canister_id, request_id, data)
      request_id
    end

    # Reads the state of a canister.
    #
    # @param canister_id [String] The ID of the target canister.
    # @param data [Hash] The data to be sent in the read state request.
    # @return [Object] The response from the canister.
    def read_state_endpoint(canister_id, data)
      @client.read_state(canister_id, data)
    end

    # Sends a raw query request to a canister and handles the response.
    #
    # @param canister_id [String] The ID of the target canister.
    # @param method_name [String] The name of the method to be called.
    # @param arg [String] The argument to be passed to the method.
    # @param return_type [Object] The expected type of the return value.
    # @param effective_canister_id [String] The effective canister ID (optional).
    # @return [Object] The decoded response from the canister.
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

    # Sends a raw update request to a canister and handles the response.
    #
    # @param canister_id [String] The ID of the target canister.
    # @param method_name [String] The name of the method to be called.
    # @param arg [String] The argument to be passed to the method.
    # @param return_type [Object] The expected type of the return value.
    # @param effective_canister_id [String] The effective canister ID (optional).
    # @param kwargs [Hash] Additional keyword arguments.
    # @return [Object] The decoded response from the canister.
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
          IcAgent::Candid.decode(result.to_hex, return_type)
        else
          # Some canisters don't use DIDL (e.g. they might encode using json instead)
          result
        end
      else
        raise Exception, "Timeout to poll result, current status: #{status.to_s}"
      end
    end

    # Sends a raw read state request to a canister and handles the response.
    #
    # @param canister_id [String] The ID of the target canister.
    # @param paths [Array] The paths to read from the canister's state.
    # @param [TrueClass] bls_verify
    # @return [Object] The decoded response from the canister.
    def read_state_raw(canister_id, paths, bls_verify = true)
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
      cert = CBOR.decode(d.value['certificate'])

      if bls_verify
        verify(cert, canister_id) ? cert : false
      else
        cert
      end
    end

    # Retrieves the status and certificate of a request from a canister.
    #
    # @param canister_id [String] The ID of the target canister.
    # @param req_id [String] The ID of the request.
    # @return [Array] The status and certificate of the request.
    def request_status_raw(canister_id, req_id)
      paths = [['request_status', req_id]]
      cert = read_state_raw(canister_id, paths)
      status = IcAgent::Certificate.lookup(['request_status', req_id, 'status'], cert)
      [status, cert]
    end

    # Polls a canister for the status of a request.
    #
    # @param canister_id [String] The ID of the target canister.
    # @param req_id [String] The ID of the request.
    # @param delay [Integer] The delay between each poll attempt (in seconds).
    # @param timeout [Integer] The maximum timeout for polling.
    def poll(canister_id, req_id, delay = 1, timeout = IcAgent::DEFAULT_POLL_TIMEOUT_SECS)
      status = nil
      cert = nil
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

    # Verify a BLS signature
    # The signature must be exactly 48 bytes (compressed G1 element)
    # The key must be exactly 96 bytes (compressed G2 element)
    def verify(cert, canister_id)
      signature_hex = IcAgent::Certificate.signature(cert).str2hex
      tree = IcAgent::Certificate.tree(cert)
      delegation = IcAgent::Certificate.delegation(cert)
      root_hash = IcAgent::Certificate.reconstruct(tree).str2hex
      msg = IcAgent::IC_STATE_ROOT_DOMAIN_SEPARATOR + root_hash
      der_key = check_delegation(delegation, canister_id, true)
      public_key_hash = extract_der(der_key).str2hex

      public_key = BLS::PointG2.from_hex(public_key_hash)
      signature = BLS::PointG1.from_hex(signature_hex)
      BLS.verify(signature, msg, public_key)
    end

    # Check the delegation and return the corresponding root key.
    def check_delegation(delegation, effective_canister_id, disable_range_check)
      return @root_key unless delegation

      begin
        cert = CBOR.decode(delegation['certificate'])
      rescue CBOR::MalformedFormatError => e
        raise TypeError, "certificate CBOR::MalformedFormatError: #{delegation['certificate']}"
      end

      path = ['subnet', delegation['subnet_id'], 'canister_ranges']
      canister_range =  IcAgent::Certificate.lookup(path, cert)

      begin
        ranges = []
        ranges_json = CBOR.decode(canister_range).values[1]

        ranges_json.each do |range_json|
          range = {}
          range['low'] = Principal.from_hex(range_json[0])
          range['high'] = Principal.from_hex(range_json[1])
          ranges << range
        end

        if !disable_range_check && !principal_is_within_ranges(effective_canister_id, ranges)
          raise AgentError 'certificate CERTIFICATE_NOT_AUTHORIZED'
        end
      rescue Exception => e
        raise AgentError "certificate INVALID_CBOR_DATA, canister_range: #{canister_range.to_s}"
      end

      path = ['subnet', delegation['subnet_id'], 'public_key']
      IcAgent::Certificate.lookup(path, cert)
    end

    def principal_is_within_ranges(principal, ranges)
      ranges.each do |range|
        return true if range['low'].lt_eq(principal) && range['high'].gt_eq(principal)
      end
      false
    end

    # Extract the BLS public key from the DER buffer.
    def extract_der(der_buf)
      bls_der_prefix = OpenSSL::BN.from_hex(IcAgent::BLS_DER_PREFIX).to_s(2)
      expected_length = bls_der_prefix.bytesize + IcAgent::BLS_KEY_LENGTH
      if der_buf.bytesize != expected_length
        raise TypeError, "BLS DER-encoded public key must be #{expected_length} bytes long"
      end

      prefix = der_buf.byteslice(0, bls_der_prefix.bytesize)
      if prefix != bls_der_prefix
        raise TypeError, "BLS DER-encoded public key is invalid. Expect the following prefix: #{bls_der_prefix}, but get #{prefix}"
      end

      der_buf.byteslice(bls_der_prefix.bytesize..-1)
    end
  end
end
