require "test_helper"

class CommandStatusCodeTest < SystemTest
  def test_exit_status_1_when_not_logged_in
    run_command_and_stop 'qc', fail_on_error: false
    assert_equal 1, last_command_started.exit_status
  end
end
