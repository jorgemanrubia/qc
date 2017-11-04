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
      ensure
        dump_quant_connect_proxy if fake_mode?
      end

      exit success ? 0 : 1
    end

    private

    def quant_connect_proxy
      @quant_connect_proxy ||= begin
        credentials = Qc::Credentials.read_from_home
        if fake_mode?
          Qc::QuantConnectFakeProxy.new(credentials)
        else
          Qc::QuantConnectProxy.new(credentials)
        end
      end
    end

    def fake_mode?
      ENV['FAKE_PROXY']
    end

    def dump_quant_connect_proxy
      content = Marshal.dump quant_connect_proxy
      File.open('.qc/fake_proxy.obj', 'w') {|file| file.write(content) }
    end
  end
end
