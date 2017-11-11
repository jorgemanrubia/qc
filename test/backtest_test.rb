require "test_helper"

class CompileTest < SystemTest
  def test_backtest_fails_when_project_hasnt_been_compiled
    prepare_qc_project_with_files 'BasicAlgo.cs'
    run_command 'qc backtest'
    assert_match(/project not compiled/i, last_command.output)
    assert_equal 1, last_command.exit_status
  end

  def test_backtest_works
    prepare_compiled_qc_project_with_files 'BasicAlgo.cs'
    run_command 'qc backtest'
    assert_match(/Waiting for backtest to finish/i, last_command.output)
    assert_match(/Bactest finished/i, last_command.output)
    assert_equal 0, last_command.exit_status
  end

end
