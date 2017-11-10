module Qc
  class Credentials < Struct.new(:user_id, :access_token)
    FILE_NAME = 'credentials.yml'

    def self.read_from_home
      return nil unless ::File.exists?(credentials_file)
      YAML.load_file credentials_file
    end

    def save_to_home
      FileUtils.mkdir_p(Qc::Util.home_dir)
      ::File.open(self.class.credentials_file, 'w') do |file|
        file.write self.to_yaml
      end
    end

    def destroy
      FileUtils.remove(self.class.credentials_file)
    end

    def self.credentials_file
      ::File.join(Qc::Util.home_dir, FILE_NAME)
    end
  end
end
