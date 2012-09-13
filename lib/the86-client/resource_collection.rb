require "addressable/uri"

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

    attr_accessor :parameters

    def with_parameters(parameters)
      self.class.new(
        @connection,
        @path,
        @klass,
        @parent
      ).tap do |collection|
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

    # Load the next page of records, based on the pagination header, e.g.
    # Link: <http://example.org/api/v1/groups/a/conversations?bumped_before=time>; rel="next"
    def more
      if more?
        url = Addressable::URI.parse(http_response.links[:next])
        self.class.new(
          @connection,
          url.path,
          @klass,
          @parent
        ).tap do |collection|
          collection.parameters = url.query_values
        end
      else
        raise PaginationError, %{Collection has no 'Link: <url>; rel="next"' header}
      end
    end

    # Whether there are more resources on a subsequent page.
    # See documentation for #more method.
    def more?
      http_response.links.key? :next
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

    def http_response
      @_http_response ||= @connection.get(
        path: @path,
        parameters: @parameters,
        status: 200
      )
    end

    def records
      @records || http_response.data
    end

  end
end
