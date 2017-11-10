require 'test_helper'

require 'support/files_helper'
require 'support/qc_helper'
require 'support/commands_helper'

class SystemTest < Minitest::Test
  include FilesHelper
  include QcHelper
  include CommandsHelper

  USE_VCR = true

  def setup
    setup_file_fixtures
    turn_vcr_on
  end

  def teardown
    turn_vcr_off
  end

  private

  def turn_vcr_on
    if USE_VCR
      VCR.insert_cassette name
    else
      WebMock.allow_net_connect!
      VCR.turn_off!
    end
  end

  def turn_vcr_off
    if USE_VCR
      VCR.eject_cassette
    end
  end
end
