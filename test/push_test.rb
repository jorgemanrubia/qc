require "test_helper"

class PushTest < SystemTest
  def setup
    super

    prepare_local_files 'file_1.cs', 'file_2.cs'
    create_empty_quant_connect_project 'my project'
    sign_in
    init_qc_project 1
  end

  def test_initial_push_should_push_all_the_files
    run_command 'qc push'
    assert_match(/uploading file_1.cs.../, last_command.output)
    assert_match(/uploading file_2.cs.../, last_command.output)
    assert_files_were_uploaded 'file_1.cs', 'file_2.cs'
  end

  def test_a_second_push_without_changing_any_file_should_not_push_any_file
    run_command 'qc push'
    run_command 'qc push'
    refute_match(/uploading file_1.cs.../, last_command.output)
    refute_match(/uploading file_2.cs.../, last_command.output)
  end
end