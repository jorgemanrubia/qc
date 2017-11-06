require "test_helper"

class CommandExitStatusTest < SystemTest
  def test_exit_status_1_when_not_logged_in
    run_command 'qc'
    assert_equal 1, last_command.exit_status
  end
end
