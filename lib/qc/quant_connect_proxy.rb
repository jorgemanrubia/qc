module Qc
  class QuantConnectProxy
    attr_accessor :credentials

    BASE_URL = "https://www.quantconnect.com/api/v2"

    def initialize(credentials)
      @credentials = credentials
    end

    def valid_login?
      response = perform_request :get, '/authenticate'
      response.success
    end

    def list_projects
      result = perform_request :get, '/projects/read'
      result.projects.collect do |project_json|
        Qc::Project.new(project_json['projectId'], project_json['name'])
      end
    end

    private

    def perform_request(method, path)
      timestamp = Time.now.utc.to_time.to_i
      hash = Digest::SHA256.hexdigest "#{credentials.access_token}:#{timestamp}"
      response = RestClient::Request.execute method: method, headers: {Timestamp: timestamp}, url: "#{BASE_URL}#{path}", user: credentials.user_id, password: hash
      body = response.body.empty? ? "{success: false}" : response.body
      OpenStruct.new JSON.parse(body)
    end
  end
end
