require "test_helper"

class LoginTest < SystemTest
  def test_ask_for_login_when_not_logged_in
    run_command_and_stop 'qc', fail_on_error: false
    assert_ask_for_login
  end

  def test_valid_login_command_stores_credentials
    assert_no_stored_credentials

    do_valid_login

    assert_match(/User id/, last_command_started.output)
    assert_match(/Access token/, last_command_started.output)

    assert_stored_credentials TestUser::USER_ID, TestUser::ACCESS_TOKEN
    assert_equal 0, last_command_started.exit_status
  end

  def test_invalid_login_command_wont_store_credentials
    assert_no_stored_credentials
    do_login 'some invalid user id', 'some invalid access token'
    assert_match /Invalid credentials/, last_command_started.output
    assert_no_stored_credentials
    assert_equal 1, last_command_started.exit_status
  end

  def test_logout_command_clear_credentials
    do_valid_login
    run_command_and_stop 'qc logout'
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
