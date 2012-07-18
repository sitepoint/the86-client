require "virtus"

module The86
  module Client
    class Resource

      include Virtus

      def self.create(attributes)
        new(attributes).tap(&:save)
      end

      # Criteria is limited to parent objects,
      # e.g. {site: Site.new(slug: "google")} for /sites/google/conversations
      def self.where(criteria = {})
        ResourceCollection.new(
          connection,
          api_path(criteria),
          self,
          criteria
        )
      end

      def save
        id ? save_existing : save_new
      end

      def self.api_path(params = {})
        raise "Resource must implement .api_path(params = {})"
      end

      def api_path
        "%s/%d" % [ self.class.api_path, id ]
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
        self.attributes = self.class.connection.post(
          path: self.class.api_path(attributes),
          data: sendable_attributes,
          status: 201
        )
      end

      def save_existing
        self.attributes = self.class.connection.patch(
          path: self.api_path,
          data: sendable_attributes,
          status: 200
        )
      end

      def self.connection
         @_connection = Connection.new
      end

    end
  end
end
