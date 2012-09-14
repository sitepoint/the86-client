%w{
  version
  connection
  errors
  oauth_bearer_authorization
  response

  resource
  resource_collection
  can_be_hidden
  access_token
  user
  group
  post
  conversation
  like
}.each { |r| require "the86-client/#{r}" }

module The86
  module Client

    # API entry points.

    def self.groups
      ResourceCollection.new(
        Connection.new,
        "groups",
        Group,
        nil
      )
    end

    def self.group(slug)
      Group.new(slug: slug)
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
