require 'test_helper'

require 'support/file_helper'
require 'support/login_helper'
require 'support/commands_helper'

class SystemTest < Minitest::Test
  include FileHelper
  include LoginHelper
  include CommandsHelper

  def setup
    setup_file_fixtures
    VCR.insert_cassette name
  end

  def teardown
    VCR.eject_cassette
  end

end
