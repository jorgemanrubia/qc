module CommandsHelper
  class Command < Struct.new(:exit_status, :output, :error)
  end

  def last_command
    @last_command ||= Command.new
  end

  def run_command(command_invocation)
    puts "> #{command_invocation}"
    arguments = command_invocation.split(' ')
    raise "Not invoking qc? #{command_invocation}" unless arguments.shift == 'qc'
    output, error = capture_io do
      last_command.exit_status = do_run_command(arguments) ? 0 : 1
    end
    puts output
    last_command.output = output
    last_command.error = error
  end

  def do_run_command(arguments)
    Dir.chdir project_dir do
      Qc::CLI.new.run(arguments)
    end
  end

  def type_when_prompted(*list, &block)
    $stdin.stub(:gets, proc { list.shift }, &block)
  end
end
