%w{
  version
  connection
  errors
  oauth_bearer_authorization

  resource
  resource_collection
  user
  site
  post
  conversation
}.each { |r| require "the86-client/#{r}" }

module The86
  module Client

    # API entry points.

    def self.sites
      ResourceCollection.new(
        Connection.new,
        "sites",
        Site,
        nil
      )
    end

    def self.site(slug)
      Site.new(slug: slug)
    end

    def self.users
      ResourceCollection.new(
        Connection.new,
        "users",
        User,
        nil
      )
    end

    # Configuration.
    class << self

      attr_writer :domain
      attr_writer :credentials

      def domain
        @domain ||
          raise("Domain not configured: #{name}.domain = \"example.org\"")
      end

      def credentials
        @credentials ||
          raise("Credentials not configured: #{name}.credentials = [username, password]")
      end

      def disable_https!
        @scheme = "http"
      end

      def scheme
        @scheme || "https"
      end

    end

  end
end
