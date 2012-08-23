module The86::Client
  class ResourceCollection

    include Enumerable

    # Connection is a The86::Client::Connection instance.
    # Path is the API-relative path, e.g. "users".
    # Klass is class of each record in the collection, e.g. User
    # Parent is the parent resource of this collection and its items.
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

    attr_writer :parameters

    def with_parameters(parameters)
      dup.tap do |collection|
        collection.parameters = parameters
      end
    end

    # Find and load a resource.
    #
    # If Resource#url_id is overridden, specify the attribute name.
    # TODO: the resource should know its URL attribute name.
    #
    # Note that this currently triggers an HTTP GET, then a POST:
    #   conversation.find(10).posts.create(attributes)
    # As an alternative, this only triggers the HTTP POST:
    #   conversation.build(id: 10).posts.create(attributes)
    def find(id, attribute = :id)
      build(id: id).load
    end

    def each
      records.each do |attributes|
        yield build(attributes)
      end
    end

    # Cache array representation.
    # Save building Resources for each record multiple times.
    def to_a
      @_to_a ||= super
    end

    def [](index)
      to_a[index]
    end

    private

    def records
      @records ||= @connection.get(
        path: @path,
        parameters: @parameters,
        status: 200
      )
    end

  end
end
