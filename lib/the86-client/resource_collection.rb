module The86::Client
  class ResourceCollection

    include Enumerable

    # Connection is a The86::Client::Connection instance.
    # Path is the API-relative path, e.g. "users".
    # Klass is class of each record in the collection, e.g. User
    # Attributes is a Hash of attributes common to all items in collection,
    #   and not fetched in HTTP response, e.g. parent items.
    #   e.g. for conversations: { site: Site.new(slug: "...") }
    # Records is an array of hashes, for pre-populating the collection.
    #   e.g. when an API response contains collections of child resources.
    def initialize(connection, path, klass, parent, records = nil)
      @connection = connection
      @path = path
      @klass = klass
      @parent = parent
      @records = records
    end

    def build(attributes)
      @klass.new(attributes.merge(parent: @parent))
    end

    def create(attributes)
      build(attributes).tap(&:save)
    end

    def each
      records.each do |attributes|
        yield build(attributes)
      end
    end

    # Cache array representation.
    # Save building Resources for each record multiple times.
    def to_a
      @_to_a = super
    end

    def [](index)
      to_a[index]
    end

    private

    def records
      @records ||= @connection.get(path: @path, status: 200)
    end

  end
end
