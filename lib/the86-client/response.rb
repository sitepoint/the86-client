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

    # See: http://tools.ietf.org/html/rfc5988
    def links
      @_links ||= {}.tap do |links|
        Array(headers["Link"] || headers["link"]).map do |link|
          link.match %r{\A<([^>]+)>;\s*rel="([^"]+)"\z}
        end.compact.each do |match|
          links[match[2].downcase.to_sym] = match[1]
        end
      end
    end

  end
end
