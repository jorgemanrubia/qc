require 'fileutils'
require 'yaml'
require 'rest-client'
require 'json'
require 'awesome_print'

Dir[File.join(__dir__, "qc/**/*.rb")].each { |f| require f }

module Qc
  # Your code goes here...
end
