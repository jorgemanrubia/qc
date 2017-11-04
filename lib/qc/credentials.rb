module Qc
  class Credentials < Struct.new(:user_id, :access_token)
    FILE_NAME = 'credentials.yml'

    def self.read_from_home
      return nil unless File.exists?(credentials_file)
      credentials = YAML.load_file credentials_file
      puts credentials
      nil
    end

    private

    def self.credentials_file
      File.join(Dir.home, FILE_NAME)
    end
  end
end
