module FilesHelper
  def setup_file_fixtures
    patch_home_dir
    clear_workspace
  end

  def home_dir
    expand_path('home')
  end

  def project_dir
    expand_path('project')
  end

  def expand_path(path)
    File.expand_path File.join('tmp', path)
  end

  def fixtures_dir
    File.expand_path File.join(__dir__, '..', 'file_fixtures')
  end

  def in_fixtures_dir(path)
    File.expand_path File.join(fixtures_dir, path)
  end

  def in_project_dir(path)
    File.expand_path File.join(project_dir, path)
  end

  def project_settings_file
    in_project_dir '.qc/settings.yml'
  end

  def assert_stored_project_settings(project_id: nil, file_extensions: nil)
    assert_equal project_id, project_settings.project_id if project_id
    assert_equal file_extensions, project_settings.file_extensions if file_extensions
  end

  def project_settings
    @project_settings ||= YAML.load_file project_settings_file
  end

  def prepare_local_files(*files)
    files.each do |file|
      prepare_local_file(file)
    end
  end

  def prepare_local_file(file)
    source_file = in_fixtures_dir(file)
    assert File.exist?(source_file), "Source file to copy not found: #{source_file}"
    FileUtils.cp source_file, in_project_dir(file)
  end

  private

  def patch_home_dir
    ENV['HOME'] = home_dir
  end

  def clear_workspace
    [project_dir, home_dir].each do |dir|
      FileUtils.rm_rf(dir)
      FileUtils.mkdir_p(dir)
    end
  end
end
