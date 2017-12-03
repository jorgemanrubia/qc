module Qc
  class CommandRunner
    DEFAULT_FILE_EXTENSIONS = 'cs,py'
    DEFAULT_IGNORED_FILES = ['AssemblyInfo.cs']

    SUPPORTED_COMMANDS =%i(login logout init push compile backtest open)
    COMPILE_POLLING_DELAY_IN_SECONDS = 2
    BACKTEST_DELAY_IN_SECONDS = 3

    attr_reader :quant_connect_proxy, :options
    attr_accessor :project_settings

    def initialize(quant_connect_proxy, options = OpenStruct.new)
      @quant_connect_proxy = quant_connect_proxy
      @project_settings = read_project_settings
      @options = options
    end

    def run(command)
      if command == :login
        do_run(command)
      else
        require_login do
          do_run(command)
        end
      end
    end

    def run_default
      run(:default)
    end

    private

    def credentials
      quant_connect_proxy&.credentials
    end

    def credentials=(new_credentials)
      quant_connect_proxy.credentials = new_credentials
    end

    def read_project_settings
      if ::File.exist?(project_settings_file)
        YAML.load(::File.open(project_settings_file))
      else
        build_fresh_project_settings
      end
    end

    def build_fresh_project_settings
      Qc::ProjectSettings.new.tap do |project_settings|
        project_settings.ignored_files = DEFAULT_IGNORED_FILES
      end

    end

    def logged_in?
      !!credentials
    end

    def require_login
      if credentials
        yield
      else
        puts "Please sign in by executing 'qc login' first"
        false
      end
    end

    def do_run(command)
      case command
        when :default
          do_run_default
        when *SUPPORTED_COMMANDS
          send "run_#{command}"
        else
          raise "Unknonw command '#{command}'. Supported commands: #{SUPPORTED_COMMANDS.collect(&:to_s).join(', ')}"
      end
    end

    def run_login
      puts "Please introduce your QuantConnect API credentials. You can find them in your preferences in https://www.quantconnect.com/account."
      user_id = ask_for_value 'User id:'
      access_token = ask_for_value 'Access token:'

      self.credentials = Qc::Credentials.new(user_id, access_token)

      if valid_login?
        credentials.save_to_home
        true
      else
        puts "Invalid credentials"
        false
      end
    end

    def run_init
      FileUtils.mkdir_p(Qc::Util.project_dir)
      project = ask_for_project
      self.project_settings.project_id = project.id
      self.project_settings.file_extensions = ask_for_extensions
      save_project_settings
      true
    end

    def run_logout
      credentials.destroy
      puts "Logged out successfully"
      true
    end

    def run_push
      show_title 'Push files'

      return false unless validate_initialized_project!

      sync_changed_files
      save_current_timestamp
      true
    end

    def run_compile
      show_title 'Compile'
      return false unless validate_initialized_project!

      compile = quant_connect_proxy.create_compile project_settings.project_id
      puts "Compile request sent to the queue with id #{compile.id}"

      begin
        puts "Waiting for compilation result..."
        compile = quant_connect_proxy.read_compile project_settings.project_id, compile.id
        sleep COMPILE_POLLING_DELAY_IN_SECONDS if compile.in_queue?
      end while compile.in_queue?

      puts "Compile success" if compile.success?
      puts "Compile failed" if compile.error?

      project_settings.last_compile_id = compile.id
      save_project_settings

      compile.success?
    end

    def run_backtest
      show_title 'Run backtest'
      return false unless validate_initialized_project!

      unless project_settings.last_compile_id
        puts "Project not compiled. Please run 'qc compile'"
        return false
      end

      do_run_backtest
    end

    def run_open
      show_title 'Open backtest results'
      return open_results_in_quant_connect
    end

    def open_results_in_quant_connect
      return false unless validate_initialized_project!
      return false unless validate_on_mac!

      open_workflow_file = ::File.expand_path ::File.join(__dir__, '..', '..', 'automator', 'open-qc-results.workflow')
      open_command = "automator -i #{project_settings.project_id} #{open_workflow_file}"
      puts "Opening backtest results for project #{project_settings.project_id}"
      system open_command
    end

    def do_run_default
      return false unless validate_initialized_project!

      failed = %i(push compile backtest).find do |command|
        !run(command)
      end

      !failed
    end

    def show_title(title)
      separator = '-' * title.length
      puts "\n#{separator}"
      puts title
      puts "#{separator}\n"
    end

    def do_run_backtest
      backtest = quant_connect_proxy.create_backtest project_settings.project_id, project_settings.last_compile_id, "backtest-#{project_settings.last_compile_id}"
      puts "Backtest for compile #{project_settings.last_compile_id} sent to the queue with id #{backtest.id}"
      open_results_in_quant_connect if options.open_results

      begin
        if backtest.started?
          puts "Waiting for backtest to finish (#{backtest.progress_in_percentage}\% completed)..."
        else
          puts "Waiting for backtest to start..."
        end
        backtest = quant_connect_proxy.read_backtest project_settings.project_id, backtest.id
        sleep BACKTEST_DELAY_IN_SECONDS if backtest.completed?
      end while !backtest.completed?

      puts "Backtest finished" if backtest.success?
      puts "Backtest failed" if backtest.error?

      project_settings.last_backtest_id = backtest.id
      save_project_settings

      backtest.success?
    end

    def valid_login?
      quant_connect_proxy.valid_login?
    end

    def save_project_settings
      ::File.open(project_settings_file, 'w') {|file| file.write self.project_settings.to_yaml}
    end

    def project_settings_file
      ::File.join(Qc::Util.project_dir, 'settings.yml')
    end

    def ask_for_value(question)
      puts question
      STDIN.gets.chomp
    end

    def ask_for_project
      puts "Fetching projets from Quantconnect..."
      projects = quant_connect_proxy.list_projects
      puts "Select the project you want to associate with this directory"
      projects.each.with_index do |project, index|
        puts "[#{index+1}] - #{project.name}"
      end
      index = ask_for_value "Project number?"
      index = index.to_i
      if index >=1 && index < projects.length + 1
        projects[index-1]
      else
        puts "Invalid value (please type a number between #{1} and #{projects.length})"
        ask_for_project
      end
    end

    def ask_for_extensions
      file_extensions = ask_for_value "Introduce the file extensions you want to send to QuantConnect as a comma separated list. ENTER to default '#{DEFAULT_FILE_EXTENSIONS}'"
      file_extensions = DEFAULT_FILE_EXTENSIONS if file_extensions.empty?
      file_extensions
    end


    def sync_changed_files
      if changed_files.empty?
        puts "No changes detected"
      end

      changed_files.each do |file|
        puts "Uploading #{file}..."
        content = ::File.read(file).strip
        quant_connect_proxy.put_file project_settings.project_id, ::File.basename(file), content
      end
    end

    def changed_files
      all_files = fetch_all_files

      return all_files unless project_settings.last_sync_at

      changed_files = all_files.find_all do |file|
        ::File.mtime(file) > project_settings.last_sync_at
      end

      changed_files
    end

    def fetch_all_files
      Dir["**/*.{#{project_settings.file_extensions}}"].reject{|file| ignore_file?(file) }
    end

    def ignore_file?(file)
      puts ignored_files.inspect
      ignored_files.find do |ignored_file|
        file =~ /#{ignored_file}/
      end
    end

    def ignored_files
      project_settings.ignored_files || DEFAULT_IGNORED_FILES
    end

    def save_current_timestamp
      project_settings.last_sync_at = Time.now
      save_project_settings
    end

    def validate_initialized_project!
      puts "Please run 'qc init' to initialize your project" unless initialized_project?
      initialized_project?
    end

    def validate_on_mac!
      puts "This command is only supported in macos" unless macos?
      macos?
    end

    def macos?
      host_os = RbConfig::CONFIG['host_os']
      host_os =~ /darwin|mac os/
    end

    def initialized_project?
      project_settings.project_id
    end
  end
end
