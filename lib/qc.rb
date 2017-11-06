require 'fileutils'
require 'yaml'
require 'rest-client'
require 'json'
require 'awesome_print'

require "qc/version"
require "qc/credentials"
require "qc/quant_connect_proxy"
require "qc/client"
require "qc/runner"
require "qc/project"
require "qc/project_settings"
require "qc/util"

Dir[File.join(__dir__, "support/**/*.rb")].each { |f| require f }

module Qc
  # Your code goes here...
end
