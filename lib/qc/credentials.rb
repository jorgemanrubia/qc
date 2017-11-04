module Qc
  class Credentials < Struct.new(:user_id, :access_token)
    FILE_NAME = 'credentials.yml'

    def self.read_from_home
      return nil unless File.exists?(credentials_file)
      YAML.load_file credentials_file
    end

    def save_to_home
      FileUtils.mkdir_p(self.class.credentials_directory)
      File.open(self.class.credentials_file, 'w') do |file|
        file.write self.to_yaml
      end
    end

    def self.credentials_file
      File.join(self.credentials_directory, FILE_NAME)
    end

    def self.credentials_directory
      # Not using `Dir.home` because aruba won't let you mock it
      File.join(ENV['HOME'], '.qc')
    end
  end
end
