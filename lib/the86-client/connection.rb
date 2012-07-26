require "faraday"
require "faraday_middleware"

module The86
  module Client
    class Connection

      def initialize
        @faraday = Faraday.new(url) do |conn|
          conn.request :json
          conn.response :json
          conn.basic_auth(*Client.credentials)
          conn.adapter Faraday.default_adapter
        end
      end

      def prepend(*parameters)
        @faraday.builder.insert(0, *parameters)
      end

      def get(options)
        dispatch(:get, options)
      end

      def patch(options)
        dispatch(:patch, options)
      end

      def post(options)
        dispatch(:post, options)
      end

      def dispatch(method, options)
        path = options.fetch(:path)
        data = options[:data]
        response = @faraday.run_request(method, path, data, @faraday.headers)
        assert_http_status(response, options[:status])
        response.body
      end

      private

      def url
        "%s://%s/api/v1" % [ Client.scheme, Client.domain ]
      end

      def assert_http_status(response, status)
        case response.status
        when nil, status then return
        when 401
          raise Unauthorized
        when 422
          raise ValidationFailed, "Validation failed: #{response.body.to_s}"
        when 500
          raise ServerError, internal_server_error_message(status, response)
        else
          raise Error, "Expected HTTP #{status}, got HTTP #{response.status}"
        end
      end

      def internal_server_error_message(expected_status, response)
        body = response.body
        if body["type"] && body["message"] && body["backtrace"]
          "Expected HTTP %d, got HTTP %d with error:\n%s\n%s\n\n%s" % [
            expected_status,
            response.status,
            response.body["type"],
            response.body["message"],
            response.body["backtrace"].join("\n"),
          ]
        else
          "Expected HTTP %d, got %d" % [
            expected_status,
            response.status,
          ]
        end
      end

    end
  end
end
