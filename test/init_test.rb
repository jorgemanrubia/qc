require "test_helper"

class InitTest < SystemTest
  def test_ask_for_login_when_not_logged_in
    run_command_and_stop 'qc init', fail_on_error: false
    assert_match(/Please do login by executing 'qc login' first/, last_command_started.output)
  end

  def test_ask_for_project_and_store_it_in_settings
    do_valid_login
    run_command 'qc init'
    type '1'
    last_command_started.stop

    assert_match(/My first C# project/, last_command_started.output)
    assert_stored_project_settings project_id: '799895'
  end

  private

  def assert_stored_project_settings(project_id: nil)
    credentials = YAML.load_file project_settings_file
    assert_equal project_id, credentials['project_id']
  end

  def project_settings_file
    File.join('.', '.qc', 'settings.yml')
  end
end
