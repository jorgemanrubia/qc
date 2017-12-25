require "test_helper"

class CompileTest < SystemTest
  def test_should_fail_when_no_project_initialized
    sign_in
    run_command 'qc backtest'
    assert_match /initialize your project/, last_command.output
    assert_equal 1, last_command.exit_status
  end

  def test_backtest_fails_when_project_hasnt_been_compiled
    prepare_qc_project_with_files 'BasicAlgo.cs'
    run_command 'qc backtest'
    assert_match(/project not compiled/i, last_command.output)
    assert_equal 1, last_command.exit_status
  end

  def test_backtest_works
    prepare_compiled_qc_project_with_files 'BasicAlgo.cs'
    run_command 'qc backtest'
    assert_match(/Waiting for backtest to start/i, last_command.output)
    assert_match(/Backtest finished/i, last_command.output)
    assert_match(/SharpeRatio/i, last_command.output)
    assert_equal 0, last_command.exit_status
  end

end
