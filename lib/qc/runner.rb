module Qc
  class Runner
    def initialize
    end

    def run(argv)
      command = argv[0]
      client = Qc::Client.new(quant_connect_proxy)
      success = begin
        if command
          client.execute(command.to_sym)
        else
          client.execute_default
        end
      rescue StandardError => error
        puts "Error: #{error}"
        false
      end

      exit success ? 0 : 1
    end

    private

    def quant_connect_proxy
      @quant_connect_proxy ||= Qc::QuantConnectProxy.new(Qc::Credentials.read_from_home)
    end
  end
end
