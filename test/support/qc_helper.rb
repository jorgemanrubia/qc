module QcHelper
  def do_login(user_id, access_token)
    type_when_prompted user_id, access_token do
      run_command 'qc login'
    end
  end

  def sign_in
    do_login TestUser::USER_ID, TestUser::ACCESS_TOKEN
  end

  def assert_ask_for_login
    assert_match(/Please sign in by executing 'qc login' first/, last_command.output)
  end

  def qc_proxy
    @qc_proxy ||= Qc::QuantConnectProxy.new(Qc::Credentials.new(TestUser::USER_ID, TestUser::ACCESS_TOKEN))
  end

  def create_empty_quant_connect_project(project_name)
    existing_project = find_quant_connect_project(project_name)
    if existing_project
      puts "Deleting existing project for testing: #{project_name}"
      qc_proxy.delete_project existing_project.id
    end

    qc_proxy.create_project project_name
  end

  def find_quant_connect_project(project_name)
    projects = qc_proxy.list_projects
    projects.find {|project| project.name == project_name}
  end

  def init_qc_project(project_index=1)
    type_when_prompted "#{project_index}", '' do
      run_command 'qc init'
    end
  end

  def assert_files_were_uploaded(*files)
    files.each do |file|
      assert_file_was_uploaded file
    end
  end

  def assert_file_was_uploaded(file_name)
    source_file = in_project_dir(file_name)
    source_file_content = ::File.read source_file
    file = qc_proxy.read_file project_settings.project_id, file_name
    assert_equal file_name, file.name
    assert_equal source_file_content.strip, file.content.strip
  end

  def prepare_qc_project_with_files(files)
    prepare_local_files files
    create_empty_quant_connect_project 'my project'
    sign_in
    init_qc_project 1
    run_command 'qc push'
  end
end
