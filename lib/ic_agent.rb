# frozen_string_literal: true

require_relative 'ic_agent/version'
require_relative 'ic_agent/principal'
require_relative 'ic_agent/identity'
require_relative 'ic_agent/client'
require_relative 'ic_agent/utils'
require_relative 'ic_agent/candid'
require_relative 'ic_agent/agent'
require_relative 'ic_agent/certificate'

module IcAgent
  class Error < StandardError; end
  class ValueError < StandardError; end
  class TypeError < StandardError; end
  # Your code goes here...

  IC_REQUEST_DOMAIN_SEPARATOR = "\x0Aic-request".freeze
  IC_ROOT_KEY = "\x4E\x9A\xF9\x9F\x06\x13\x26\x81\xE7\xD2\x55\x2A\x26\x17\x98\x51\xE9\xC3\x79\xB3\xC7\xBE\x88\x27\xB8\x35\x17\xFC\x84\x4E\x4C\x4F".freeze
  IC_PUBKEY_ED_DER_HEAD = '302a300506032b6570032100'
  IC_PUBKEY_SECP_DER_HERD = '3056301006072a8648ce3d020106052b8104000a034200'
  DEFAULT_POLL_TIMEOUT_SECS = 60
end
