module The86
  module Client
    class User < Resource

      attribute :id, Integer
      attribute :name, String

      def api_path; "users" end

    end
  end
end
