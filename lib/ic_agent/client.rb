require 'faraday'

module IcAgent
  class Client
    DEFAULT_TIMEOUT = 120
    DEFAULT_TIMEOUT_QUERY = 30

    # Initializes a new instance of the Client class.
    #
    # Parameters:
    # - url: The URL of the IC agent. Defaults to 'https://ic0.app'.
    def initialize(url = 'https://ic0.app')
      @url = url
      @conn = Faraday.new(url: url) do |faraday|
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
        faraday.headers['Content-Type'] = 'application/cbor'
        faraday.options.timeout = DEFAULT_TIMEOUT
        faraday.options.open_timeout = DEFAULT_TIMEOUT_QUERY
      end
    end

    # Sends a query to a canister.
    #
    # Parameters:
    # - canister_id: The ID of the canister to query.
    # - data: The data to send with the query.
    #
    # Returns: The response from the canister as a UTF-8 encoded string.
    def query(canister_id, data)
      endpoint = "/api/v2/canister/#{canister_id}/query"
      ret = @conn.post(endpoint, data)
      ret.body.force_encoding('ISO-8859-1').encode('UTF-8')
      ret.body
    end

    # Calls a function on a canister.
    #
    # Parameters:
    # - canister_id: The ID of the canister to call.
    # - req_id: The request ID.
    # - data: The data to send with the call.
    #
    # Returns: The request ID.
    def call(canister_id, req_id, data)
      endpoint = "/api/v2/canister/#{canister_id}/call"
      ret = @conn.post(endpoint, data)
      ret.body.force_encoding('ISO-8859-1').encode('UTF-8')
      req_id
    end

    # Reads the state of a canister.
    #
    # Parameters:
    # - canister_id: The ID of the canister to read the state from.
    # - data: The data to send with the read_state request.
    #
    # Returns: The response from the canister as a UTF-8 encoded string.
    def read_state(canister_id, data)
      endpoint = "/api/v2/canister/#{canister_id}/read_state"
      ret = @conn.post(endpoint, data)
      ret.body.force_encoding('ISO-8859-1').encode('UTF-8')
      ret.body
    end

    # Retrieves the status of the IC agent.
    #
    # Parameters:
    # - timeout: The timeout for the status request. Defaults to DEFAULT_TIMEOUT_QUERY.
    #
    # Returns: The response from the status endpoint as a UTF-8 encoded string.
    def status(timeout: DEFAULT_TIMEOUT_QUERY)
      endpoint = '/api/v2/status'
      ret = @conn.get(endpoint, timeout: timeout)
      puts "client.status: #{ret.body.force_encoding('ISO-8859-1').encode('UTF-8')}"
      ret.body
    end
  end
end
