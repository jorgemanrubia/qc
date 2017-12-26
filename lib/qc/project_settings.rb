module Qc
  class ProjectSettings< Struct.new(:project_id, :file_extensions, :last_sync_at, :last_compile_id, :last_backtest_id, :ignored_files, :name, :execution_count)

  end
end
