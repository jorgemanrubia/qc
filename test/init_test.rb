require "test_helper"

class InitTest < SystemTest
  def test_ask_for_login_when_not_logged_in
    run_command 'qc init'
    assert_ask_for_login
    assert_equal 1, last_command.exit_status
  end

  def test_init_asks_for_project_and_store_it_in_settings_with_default_extension
    sign_in

    type_when_prompted '2', '' do
      run_command 'qc init'
    end

    assert_match(/Basic Template Algorithm/, last_command.output)

    assert_stored_project_settings project_id: '947315', file_extensions: 'cs,py'
    assert_equal 0, last_command.exit_status
  end

  def test_init_stores_settings_with_custom_extension
    sign_in
    type_when_prompted '1', 'java,rb' do
      run_command 'qc init'
    end
    assert_stored_project_settings file_extensions: 'java,rb'
  end

end
