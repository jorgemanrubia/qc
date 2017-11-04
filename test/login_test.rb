require "test_helper"

class LoginTest < SystemTest
  def test_it_does_something
    run_command_and_stop 'qc'
    type 'pepe'
    assert_match /Please do login by running 'qc login' first/, last_command_started.output
  end
end
