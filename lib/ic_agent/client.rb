require 'faraday'

module IcAgent
  class Client
    DEFAULT_TIMEOUT = 120
    DEFAULT_TIMEOUT_QUERY = 30

    def initialize(url = "https://ic0.app")
      @url = url
      @conn = Faraday.new(url: url) do |faraday|
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
        faraday.headers['Content-Type'] = 'application/cbor'
        faraday.options.timeout = DEFAULT_TIMEOUT
        faraday.options.open_timeout = DEFAULT_TIMEOUT_QUERY
      end
    end

    def query(canister_id, data)
      endpoint = "/api/v2/canister/#{canister_id}/query"
      ret = @conn.post(endpoint, data)
      ret.body.force_encoding('ISO-8859-1').encode('UTF-8')
      return ret.body
    end

    def call(canister_id, req_id, data)
      endpoint = "/api/v2/canister/#{canister_id}/call"
      @conn.post(endpoint, data)
      ret.body.force_encoding('ISO-8859-1').encode('UTF-8')
      return req_id
    end

    def read_state(canister_id, data)
      endpoint = "/api/v2/canister/#{canister_id}/read_state"
      ret = @conn.post(endpoint, data)
      ret.body.force_encoding('ISO-8859-1').encode('UTF-8')
      return ret.body
    end

    def status(timeout: DEFAULT_TIMEOUT_QUERY)
      endpoint = "/api/v2/status"
      ret = @conn.get(endpoint, timeout: timeout)
      puts "client.status: #{ret.body.force_encoding('ISO-8859-1').encode('UTF-8')}"
      return ret.body
    end
  end
end