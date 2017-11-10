module Qc
  class QuantConnectProxy
    class RequestError < StandardError;
    end

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
      response = perform_request :get, '/projects/read'
      validate_response! response
      response.projects.collect do |project_json|
        Qc::Project.new(project_json['projectId'], project_json['name'])
      end
    end

    def delete_project(project_id)
      response = perform_request :post, '/projects/delete', payload: {projectId: project_id}
      validate_response! response
      project_id
    end

    def create_project(project_name, language: 'C#')
      response = perform_request :post, '/projects/create', payload: {name: project_name, language: language}
      validate_response! response
      project = response.projects[0]
      Qc::Project.new(project['project_id'], project['name'])
    end

    def put_file(project_id, file_name, file_content)
      response = perform_request :post, '/files/create', payload: {projectId: project_id, name: file_name, content: file_content}
      validate_response! response
      create_file_from_json_response(response.files[0])
    end


    def read_file(project_id, file_name)
      response = perform_request :post, '/files/read', payload: {projectId: project_id, name: file_name}
      validate_response! response
      create_file_from_json_response(response.files[0])
    end

    private

    def create_file_from_json_response(file_json)
      Qc::File.new(file_json['name'], file_json['content'])
    end

    def perform_request(method, path, payload: {})
      timestamp = Time.now.utc.to_time.to_i
      password_hash = Digest::SHA256.hexdigest "#{credentials.access_token}:#{timestamp}"
      response = RestClient::Request.execute method: method,
                                             headers: {Timestamp: timestamp}, url: "#{BASE_URL}#{path}",
                                             user: credentials.user_id,
                                             password: password_hash,
                                             payload: payload
      body = response.body.empty? ? '{"success": false}' : response.body
      OpenStruct.new JSON.parse(body)
    end

    def validate_response!(response)
      unless response.success
        raise RequestError, response.inspect
      end
    end
  end
end
