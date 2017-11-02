require "aruba/api"

class SystemTest < Minitest::Test
  include Aruba::Api

  def setup
    setup_aruba
  end
end
