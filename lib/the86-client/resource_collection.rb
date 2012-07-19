module The86::Client
  class ResourceCollection

    include Enumerable

    # Connection is a The86::Client::Connection instance.
    # Path is the API-relative path, e.g. "users".
    # Klass is class of each record in the collection, e.g. User
    # Attributes is a Hash of attributes common to all items in collection,
    #   and not fetched in HTTP response, e.g. parent items.
    #   e.g. for conversations: { site: Site.new(slug: "...") }
    def initialize(connection, path, klass, attributes)
      @connection = connection
      @path = path
      @klass = klass
      @attributes = attributes
    end

    def build(attributes)
      @klass.new(attributes.merge(@attributes))
    end

    def create(attributes)
      build(attributes).tap(&:save)
    end

    def each
      records.each do |attributes|
        yield @klass.new(attributes.merge(@attributes))
      end
    end

    private

    def records
      @_records ||= @connection.get(path: @path, status: 200)
    end

  end
end
