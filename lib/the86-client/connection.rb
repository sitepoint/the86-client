require "addressable/uri"
require "faraday"
require "faraday_middleware"

module The86
  module Client
    class Connection

      class << self
        # Parameters for Faraday's connection.adapter method, e.g:
        # [:rack, SomeApp]
        attr_writer :faraday_adapter
        def faraday_adapter
          @faraday_adapter || Faraday.default_adapter
        end

      end

      attr_accessor :timeout, :open_timeout

      def initialize
        # Default some basic connection options
        @timeout = 15 #seconds
        @open_timeout = 3 #seconds

        @faraday = Faraday.new(url) do |conn|
          conn.request :json
          conn.response :json
          conn.basic_auth(*Client.credentials)
          conn.adapter *self.class.faraday_adapter
        end
      end

      # Insert a Faraday middleware at the top of the chain.
      def prepend(*parameters)
        @faraday.builder.insert(0, *parameters)
      end

      def get(options)
        dispatch(:get, options)
      end

      def patch(options)
        # TODO: extract HTTP method override into Faraday middleware.
        options[:headers] ||= {}
        options[:headers]["X-Http-Method-Override"] = "patch"
        dispatch(:post, options)
      end

      def post(options)
        dispatch(:post, options)
      end
      
      def delete(options)
        dispatch(:delete, options)
      end

      private

      # Dispatch the HTTP request.
      # Returns the The86::Client::Response which contains the
      # HTTP status code, headers and decoded response body.
      def dispatch(method, options)
        path = options.fetch(:path)
        parameters = options[:parameters]
        data = options[:data]

        if parameters
          path = Addressable::URI.parse(path).tap do |uri|
            uri.query_values = (uri.query_values || {}).merge(parameters)
          end.to_s
        end

        headers = @faraday.headers.merge(options[:headers] || {})
        response = @faraday.run_request(method, path, data, headers) do |req|
          req.options[:timeout] = @timeout
          req.options[:open_timeout] = @open_timeout
        end

        assert_http_status(response, options[:status])

        ::The86::Client::Response.new(
          response.status,
          response.headers,
          response.body
        )
      end

      def url
        "%s://%s/api/v1" % [ Client.scheme, Client.domain ]
      end

      def assert_http_status(response, status)
        case response.status
        when nil, 200, 201, 204, status then return
        when 401
          raise Unauthorized
        when 404
          raise NotFoundError, ("Not Found: #{response.env[:url].to_s}" rescue response)
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
