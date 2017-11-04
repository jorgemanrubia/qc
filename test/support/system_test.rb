require "aruba/api"

class SystemTest < Minitest::Test
  include Aruba::Api

  def setup
    setup_aruba
    set_environment_variable 'HOME', home_dir
  end

  def home_dir
    expand_path('.')
  end
end
