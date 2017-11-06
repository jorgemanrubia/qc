module Qc
  class Client
    attr_reader :quant_connect_proxy
    attr_accessor :project_settings

    def initialize(quant_connect_proxy)
      @quant_connect_proxy = quant_connect_proxy
      @project_settings = Qc::ProjectSettings.new
    end

    def credentials
      quant_connect_proxy&.credentials
    end

    def execute(command)
      if command == :login
        do_execute(command)
      else
        require_login do
          do_execute(command)
        end
      end
    end

    def execute_default
      execute(:default)
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

    def do_execute(command)
      case command
        when :default
          puts "Default command not implemented yet..."
          true
        when :login
          execute_login
        when :logout
          execute_logout
        when :init
          execute_init
        else
          raise "Unknonw command #{command}"
      end
    end

    def execute_login
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

    def execute_init
      project = ask_for_project
      FileUtils.mkdir_p(Qc::Util.project_dir)
      self.project_settings.project_id = project.id
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
      STDIN.gets.chomp
    end

    def ask_for_project
      puts "Fetching projets from Quantconnect..."
      projects = quant_connect_proxy.list_projects
      puts "Please select the project you want to associate with this directory"
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

    def execute_logout
      credentials.destroy
      puts "Logged out successfully"
      true
    end
  end
end
