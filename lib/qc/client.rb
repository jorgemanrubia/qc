module Qc
  class Client
    attr_reader :quant_connect_proxy

    def initialize(quant_connect_proxy)
      @quant_connect_proxy = quant_connect_proxy
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

    def ask_for_value(question)
      puts question
      STDIN.gets.chomp
    end

    def execute_logout
      credentials.destroy
      puts "Logged out successfully"
      true
    end
  end
end
