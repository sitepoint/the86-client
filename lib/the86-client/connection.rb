require "faraday"
require "faraday_middleware"

module The86
  module Client
    class Connection

      def initialize
        @faraday = Faraday.new(url) do |conn|
          conn.request :json
          conn.response :json
          conn.adapter Faraday.default_adapter
        end
      end

      def post(options)
        path = options.fetch(:path)
        data = options.fetch(:data)
        response = @faraday.post(path, data)
        assert_http_status(response, options[:status])
        response.body
      end

      private

      def url
        "https://#{::The86::Client.domain}/api/v1"
      end

      def assert_http_status(response, status)
        case response.status
        when nil, status then return
        when 401
          raise Unauthorized
        when 422
          raise ValidationFailed, "Validation failed: #{response.body.to_s}"
        else
          raise Error, "Expected HTTP 201, got HTTP #{response.status}"
        end
      end

    end
  end
end
