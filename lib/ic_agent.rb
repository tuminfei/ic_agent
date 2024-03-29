# frozen_string_literal: true

require 'treetop'

require_relative 'ic_agent/version'
require_relative 'ic_agent/principal'
require_relative 'ic_agent/identity'
require_relative 'ic_agent/client'
require_relative 'ic_agent/utils'
require_relative 'ic_agent/candid'
require_relative 'ic_agent/agent'
require_relative 'ic_agent/certificate'
require_relative 'ic_agent/system_state'
require_relative 'ic_agent/canister'

require_relative 'ic_agent/ast/nodes/named_nodes'
require_relative 'ic_agent/ast/nodes/statement_nodes'
require_relative 'ic_agent/ast/nodes/string_literal'
require_relative 'ic_agent/ast/parser'
require_relative 'ic_agent/ast/statement_parser'
require_relative 'ic_agent/ast/writer'
require_relative 'ic_agent/ast/assembler'

require_relative 'ic_agent/common/ledger'
require_relative 'ic_agent/common/cycles_wallet'
require_relative 'ic_agent/common/governance'
require_relative 'ic_agent/common/management'

module IcAgent
  class Error < StandardError; end
  class ValueError < StandardError; end
  class TypeError < StandardError; end
  class AgentError < StandardError; end
  class BaseException < StandardError; end

  IC_REQUEST_DOMAIN_SEPARATOR = "\x0Aic-request"
  IC_ROOT_KEY = "\x4E\x9A\xF9\x9F\x06\x13\x26\x81\xE7\xD2\x55\x2A\x26\x17\x98\x51\xE9\xC3\x79\xB3\xC7\xBE\x88\x27\xB8\x35\x17\xFC\x84\x4E\x4C\x4F"
  IC_PUBKEY_ED_DER_HEAD = '302a300506032b6570032100'
  IC_PUBKEY_SECP_DER_HERD = '3056301006072a8648ce3d020106052b8104000a034200'
  DEFAULT_POLL_TIMEOUT_SECS = 60
  IC_STATE_ROOT_DOMAIN_SEPARATOR = "\ric-state-root".str2hex
  BLS_KEY_LENGTH = 96
  BLS_DER_PREFIX = '308182301d060d2b0601040182dc7c0503010201060c2b0601040182dc7c05030201036100'
end
