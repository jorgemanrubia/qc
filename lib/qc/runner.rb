module Qc
  class Runner
    attr_reader :quant_connect_proxy

    def initialize(quant_connect_proxy)
      @quant_connect_proxy = quant_connect_proxy
    end

    def run(argv)
      command = argv[0]
      client = Qc::Client.new(quant_connect_proxy)
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
  end
end
