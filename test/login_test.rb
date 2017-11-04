require "test_helper"

class LoginTest < SystemTest
  def test_it_does_something
    run_command_and_stop 'qc'
    assert_match /Please do login by executing 'qc login' first/, last_command_started.output
  end

  def test_login_command_stores_credentials
    run_command 'qc login'
    type 'my user id'
    type 'my access token'
    last_command_started.stop

    assert_match /User id/, last_command_started.output
    assert_match /Access token/, last_command_started.output

    credentials = YAML.load_file File.join(home_dir, '.qc', 'credentials.yml')
    assert 'my user id', credentials['user_id']
    assert 'my access token', credentials['access_token']
  end


end
