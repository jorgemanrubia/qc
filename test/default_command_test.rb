require "test_helper"

class CompileTest < SystemTest
  def test_should_fail_when_no_project_initialized
    sign_in
    run_command 'qc'
    assert_match /initialize your project/, last_command.output
    assert_equal 1, last_command.exit_status
  end

  def test_default_command_test_will_execute_push_compile_and_backtest_in_sequence
    prepare_local_project_linked_with_qc_with_files 'BasicAlgo.cs'
    run_command 'qc'
    assert_match(/Waiting for backtest to finish/i, last_command.output)
    assert_match(/Backtest finished/i, last_command.output)
    assert_equal 0, last_command.exit_status
  end

  def test_default_command_test_will_exit_with_status_1_when_a_command_in_the_chain_fails
    prepare_local_project_linked_with_qc_with_files 'AlgoThatWontCompile.cs'
    run_command 'qc'
    assert_match(/compile failed/i, last_command.output)
    assert_equal 1, last_command.exit_status
  end

end
