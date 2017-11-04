require "test_helper"

class LoginTest < SystemTest
  def test_ask_for_login_when_not_logged_in
    run_command_and_stop 'qc', fail_on_error: false
    assert_match(/Please do login by executing 'qc login' first/, last_command_started.output)
  end

  def test_login_command_stores_credentials
    assert_no_stored_credentials

    do_login 'my user id', 'my access token'

    assert_match(/User id/, last_command_started.output)
    assert_match(/Access token/, last_command_started.output)

    assert_stored_credentials 'my user id', 'my access token'
  end

  def test_logout_command_clear_credentials
    do_login 'my user id', 'my access token'
    run_command_and_stop 'qc logout'
    puts last_command_started.output
    assert_no_stored_credentials
  end

  private

  def assert_no_stored_credentials
    refute File.exist?(credentials_file)
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
