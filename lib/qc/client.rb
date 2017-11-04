module Qc
  class Client
    attr_reader :credentials

    def initialize
      @credentials = Credentials.read_from_home
    end

    def run
      require_login do

      end
    end

    def logged_in?
      !!credentials
    end

    def require_login
      if credentials
        yield
      else
        puts "Please do login by running 'qc login' first"
        false
      end
    end
  end
end
