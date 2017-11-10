require "test_helper"

class PushTest < SystemTest
  def test_initial_push_should_push_all_the_files
    prepare_local_files 'file_1.cs', 'file_2.cs'
    create_empty_quant_connect_project 'my project'
    sign_in
    init_qc_project 1

    run_command 'qc push'
    assert_match(/uploading file_1.cs.../, last_command.output)
    assert_match(/uploading file_2.cs.../, last_command.output)
    assert_files_were_uploaded 'file_1.cs', 'file_2.cs'
  end
end
