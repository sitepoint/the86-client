require "the86-client/connection"
require "the86-client/errors"
require "the86-client/resource"
require "the86-client/resource_collection"
require "the86-client/version"

# Resources
require "the86-client/user"
require "the86-client/site"
require "the86-client/post"
require "the86-client/conversation"

module The86
  module Client

    def self.domain= domain
      @domain = domain
    end

    def self.domain
      @domain || raise("Domain not configured: #{name}.domain = \"example.org\"")
    end

  end
end
