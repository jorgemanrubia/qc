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

  def do_login(user_id, access_token)
    run_command 'qc login'
    type user_id
    type access_token
    last_command_started.stop
  end
end
