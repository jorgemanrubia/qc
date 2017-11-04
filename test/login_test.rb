require "test_helper"

class LoginTest < SystemTest
  def test_it_does_something
    run_command_and_stop 'qc'
    assert_match /Please do login by executing 'qc login' first/, last_command_started.output
  end

  def test_login_command_stores_credentials
    assert_no_stored_credentials

    run_command 'qc login'
    type 'my user id'
    type 'my access token'
    last_command_started.stop

    assert_match /User id/, last_command_started.output
    assert_match /Access token/, last_command_started.output

    assert_stored_credentials 'my user id', 'my access token'
  end

  private

  def assert_no_stored_credentials
    refute File.exists?(credentials_file)
  end

  def assert_stored_credentials(user_id, access_token)
    credentials = YAML.load_file credentials_file
    assert user_id, credentials['user_id']
    assert access_token, credentials['access_token']
  end

  def credentials_file
    File.join(home_dir, '.qc', 'credentials.yml')
  end
end
