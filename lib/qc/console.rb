module Qc
  class Console
    def initialize
    end

    def run(argv)
      options = parse_options(argv)

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

    def parse_options(args)
      options = OpenStruct.new

      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: qc [command] [options]"

        opts.separator ""
        opts.separator "Supported commands: #{Qc::CommandRunner::SUPPORTED_COMMANDS.join(', ')}"
        opts.separator "When no command provided it will execute: 'push compile backtest' in sequence"

        opts.separator ""
        opts.separator "Common options:"

        opts.on("-h", "--help", "Show this message") do
          puts opts
          exit 0
        end

        opts.on("--version", "Show version") do
          puts Qc::VERSION
          exit 0
        end
      end

      opt_parser.parse!(args)
      options
    end
  end
end
