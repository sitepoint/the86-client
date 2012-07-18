module The86::Client
  class Post < Resource

    attribute :id, Integer
    attribute :content, String
    attribute :created_at, DateTime
    attribute :updated_at, DateTime

  end
end
