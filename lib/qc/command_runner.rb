module Qc
  class CommandRunner
    DEFAULT_FILE_EXTENSIONS = 'cs,py'

    attr_reader :quant_connect_proxy
    attr_accessor :project_settings

    def initialize(quant_connect_proxy)
      @quant_connect_proxy = quant_connect_proxy
      @project_settings = Qc::ProjectSettings.new
    end

    def credentials
      quant_connect_proxy&.credentials
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


    def logged_in?
      puts "VALUE: #{!!credentials}"
      !!credentials
    end

    def require_login
      if credentials
        yield
      else
        puts "Please do login by executing 'qc login' first"
        false
      end
    end

    def do_run(command)
      case command
        when :default
          puts "Default command not implemented yet..."
          true
        when :login
          run_login
        when :logout
          run_logout
        when :init
          run_init
        else
          raise "Unknonw command #{command}"
      end
    end

    def run_login
      puts "Please introduce your QuantConnect credentials. You can find them in your preferences in https://www.quantconnect.com/account."
      user_id = ask_for_value 'User id:'
      access_token = ask_for_value 'Access token:'

      quant_connect_proxy.credentials = Qc::Credentials.new(user_id, access_token)

      if quant_connect_proxy.valid_login?
        Qc::Credentials.new(user_id, access_token).save_to_home
        true
      else
        puts "Invalid credentials"
        false
      end
    end

    def run_init
      FileUtils.mkdir_p(Qc::Util.project_dir)

      self.project_settings.project_id = ask_for_project.id
      self.project_settings.file_extensions = ask_for_extensions

      save_project_settings
    end

    def save_project_settings
      File.open(project_settings_file, 'w') {|file| file.write self.project_settings.to_yaml }
    end

    def project_settings_file
      File.join(Qc::Util.project_dir, 'settings.yml')
    end

    def ask_for_value(question)
      puts question
      v = STDIN.gets
      v.chomp
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

    def run_logout
      credentials.destroy
      puts "Logged out successfully"
      true
    end
  end
end
