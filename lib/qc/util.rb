module Qc
  class Util
    def self.home_dir
      # Not using `Dir.home` because aruba won't let you mock it
      File.join(ENV['HOME'], '.qc')
    end

    def self.project_dir
      File.join('.', '.qc')
    end
  end
end
