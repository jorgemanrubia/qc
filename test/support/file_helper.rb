module FileHelper
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

  def project_settings_file
    File.join(project_dir, '.qc', 'settings.yml')
  end

  def assert_stored_project_settings(project_id: nil, file_extensions: nil)
    credentials = YAML.load_file project_settings_file
    assert_equal project_id, credentials['project_id'] if project_id
    assert_equal file_extensions, credentials['file_extensions'] if file_extensions
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
