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
      payload = {projectId: project_id, name: file_name, content: file_content}
      response = perform_request :post, '/files/update', payload: payload
      if missing_file_error?(response)
        response = perform_request :post, '/files/create', payload: payload
      end
      validate_response! response
      create_file_from_json_response(response.files[0])
    end

    def read_file(project_id, file_name)
      response = perform_request :post, '/files/read', payload: {projectId: project_id, name: file_name}
      validate_response! response
      create_file_from_json_response(response.files[0])
    end

    def create_compile(project_id)
      response = perform_request :post, '/compile/create', payload: {projectId: project_id}
      validate_response! response
      create_compile_from_json_response(response)
    end

    def read_compile(project_id, compile_id)
      response = perform_request :get, '/compile/read', params: {projectId: project_id, compileId: compile_id}
      validate_response! response
      create_compile_from_json_response(response)
    end

    def create_backtest(project_id, compile_id, backtest_name)
      response = perform_request :post, '/backtests/create', payload: {projectId: project_id, compileId: compile_id, backtestName: backtest_name}
      validate_response! response
      create_backtest_from_json_response(response)
    end

    def read_backtest(project_id, backtest_id)
      response = perform_request :get, '/backtests/read', params: {projectId: project_id, backtestId: backtest_id}
      validate_response! response
      create_backtest_from_json_response(response)
    end

    private

    def create_backtest_from_json_response(response)
      Qc::Backtest.new(response.backtestId, response.name, response.completed, response.progress.to_f, response.result, response.success)
    end

    def create_compile_from_json_response(response)
      Qc::Compile.new(response.compileId, response.state)
    end

    def missing_file_error?(response)
      !response.success && (response.errors.join("\n") =~ /file not found/i)
    end

    def create_file_from_json_response(file_json)
      Qc::File.new(file_json['name'], file_json['content'])
    end

    def perform_request(method, path, payload: {}, params: {})
      timestamp = Time.now.utc.to_time.to_i
      password_hash = Digest::SHA256.hexdigest "#{credentials.access_token}:#{timestamp}"
      headers = {Timestamp: timestamp}.merge(params: params)
      response = RestClient::Request.execute method: method,
                                             url: "#{BASE_URL}#{path}",
                                             headers: headers,
                                             user: credentials.user_id,
                                             content_type: :json,
                                             accept: :json,
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
