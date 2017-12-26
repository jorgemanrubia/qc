module Qc
  class CLI
    def initialize
    end

    def run(argv)
      parsed_options = parse_options(argv)

      command = argv[0]
      client = Qc::CommandRunner.new(quant_connect_proxy, parsed_options)
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

    def parse_options(args)
      parsed_options = OpenStruct.new

      opt_parser = OptionParser.new do |options|
        options.banner = "Usage: qc [command] [options]"

        options.separator ""
        options.separator "Supported commands: #{Qc::CommandRunner::SUPPORTED_COMMANDS.join(', ')}"
        options.separator "When no command provided it will execute: 'push compile backtest' in sequence"

        options.separator ""
        options.separator "Common options:"

        options.on("-o", "--open", "Open backtest results in QuantConnect. Only for `qc` or `qc backtest` commands.") do
          parsed_options.open_results = true
        end

        options.on("-t", "--tradervue", "Import the results into Tradervue. You must set env vars TRADERVUE_LOGIN and TRADERVUE_PASSWORD") do
          parsed_options.import_into_tradervue = true
        end

        options.on("-h", "--help", "Show this message") do
          puts options
          exit 0
        end

        options.on("--version", "Show version") do
          puts Qc::VERSION
          exit 0
        end
      end

      opt_parser.parse!(args)
      parsed_options
    end
  end
end
