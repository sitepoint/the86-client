module The86::Client

  # Representation of an HTTP response.
  class Response

    # status: The numeric HTTP status.
    # headers: Hash of HTTP response headers.
    # data: The decoded body of the response.
    def initialize(status, headers, data)
      @status = status
      @headers = headers
      @data = data
    end

    attr_reader :status
    attr_reader :headers
    attr_reader :data

  end
end
