require "virtus"

module The86
  module Client
    class Resource

      include Virtus

      # Assigned by Virtus constructor.
      attr_accessor :oauth_token

      ##
      # Class methods

      class << self

        def create(attributes)
          new(attributes).tap(&:save)
        end

        # Criteria is limited to parent objects,
        # e.g. {site: Site.new(slug: "google")} for /sites/google/conversations
        def where(criteria = {})
          ResourceCollection.new(
            Connection.new,
            api_path(criteria),
            self,
            criteria
          )
        end

        def api_path(params = {})
          raise "Resource must implement .api_path(params = {})"
        end

      end

      ##
      # Instance methods

      def save
        id ? save_existing : save_new
      end

      def api_path(params)
        "%s/%d" % [ self.class.api_path(params), id ]
      end

      def sendable_attributes
        attributes.reject do |key, value|
          [:id, :created_at, :updated_at].include?(key) ||
            value.kind_of?(Resource) ||
            value.nil?
        end
      end


      private

      def save_new
        self.attributes = connection.post(
          path: self.class.api_path(attributes),
          data: sendable_attributes,
          status: 201
        )
      end

      def save_existing
        self.attributes = connection.patch(
          path: self.api_path(attributes),
          data: sendable_attributes,
          status: 200
        )
      end

      def connection
        Connection.new.tap do |c|
          c.prepend OauthBearerAuthorization, oauth_token if oauth_token
        end
      end

    end
  end
end
