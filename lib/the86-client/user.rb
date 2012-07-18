module The86
  module Client
    class User < Resource

      attribute :id, Integer
      attribute :name, String
      attribute :created_at, DateTime
      attribute :updated_at, DateTime

      def self.api_path(params = {})
        "users"
      end

    end
  end
end
