require "test_helper"

class QcTest < SystemTest
  def test_it_does_something
    run_command 'qc'
    type 'pepe'
    last_command_started.stop

    puts "*"*100
    puts last_command_started.output
    puts "*"*100
  end
end
