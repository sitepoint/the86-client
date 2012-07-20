module The86
  module Client
    class User < Resource

      attribute :id, Integer
      attribute :name, String
      attribute :created_at, DateTime
      attribute :updated_at, DateTime

      collection "users"

    end
  end
end
