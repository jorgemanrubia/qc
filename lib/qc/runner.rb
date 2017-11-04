module Qc
  class Runner
    def initialize
    end

    def run(argv)
      command = argv[0]
      client = Qc::Client.new(build_quant_connect_proxy)
      result = if command
                 client.execute(command.to_sym)
               else
                 client.execute_default
               end
      if result
        exit 0
      else
        exit 1
      end
    rescue StandardError => error
      puts "Error: #{error}"
      exit 1
    end

    private

    def build_quant_connect_proxy
      Qc::QuantConnectProxy .new(Qc::Credentials.read_from_home)
    end
  end
end
