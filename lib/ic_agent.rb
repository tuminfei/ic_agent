# frozen_string_literal: true

require_relative "ic_agent/version"
require_relative "ic_agent/principal"
require_relative "ic_agent/indentity"
require_relative "ic_agent/client"
require_relative "ic_agent/utils"
require_relative "ic_agent/candid"

module IcAgent
  class Error < StandardError; end
  class ValueError < StandardError; end
  class TypeError < StandardError; end
  # Your code goes here...
end
