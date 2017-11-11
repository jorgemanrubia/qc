require "test_helper"

class CompileTest < SystemTest
  def test_successful_compile
    prepare_qc_project_with_files 'BasicAlgo.cs'
    run_command 'qc compile'
    assert_match(/compile success/i, last_command.output)
    assert_equal 0, last_command.exit_status
    compile_id = last_command.output[/([[:alnum:]]+\-[[:alnum:]]+)/,1]
    assert_stored_project_settings last_compile_id: compile_id
  end

  def test_compile_with_errors
    prepare_qc_project_with_files 'AlgoThatWontCompile.cs'
    run_command 'qc compile'
    assert_match(/compile failed/i, last_command.output)
    assert_equal 1, last_command.exit_status
  end

end
