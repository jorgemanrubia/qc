module Qc
  class Console
    def initialize
    end

    def run(argv)
      command = argv[0]
      client = Qc::CommandRunner.new(quant_connect_proxy)
      success = begin
        if command
          client.run(command.to_sym)
        else
          client.run_default
        end
      rescue StandardError => error
        puts "Error: #{error}"
        false
      end

      success
    end

    private

    def quant_connect_proxy
      @quant_connect_proxy ||= Qc::QuantConnectProxy.new(Qc::Credentials.read_from_home)
    end
  end
end
