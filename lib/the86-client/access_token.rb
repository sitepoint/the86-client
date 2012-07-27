module The86
  module Client
    class AccessToken < Resource

      attribute :id, Integer
      attribute :token, String
      attribute :created_at, DateTime
      attribute :updated_at, DateTime

      belongs_to :user

      path "access_tokens"

    end
  end
end
