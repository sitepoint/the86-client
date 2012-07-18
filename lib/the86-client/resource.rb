require "virtus"

module The86
  module Client
    class Resource

      include Virtus

      def self.create(attributes)
        new(attributes).tap(&:save)
      end

      def save
        id ? save_existing : save_new
      end

      def api_path
        raise "Resource must implement #api_path"
      end

      def sendable_attributes
        attributes.reject { |key| [:id, :created_at, :updated_at].include?(key) }
      end

      private

      def save_new
        self.attributes = self.class.connection.post(
          path: api_path,
          data: sendable_attributes,
          status: 201
        )
      end

      def save_existing
        raise "TODO"
      end

      def self.connection
         @_connection = Connection.new
      end

    end
  end
end
