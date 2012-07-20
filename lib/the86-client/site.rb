module The86::Client
  class Site < Resource

    attribute :id, Integer
    attribute :slug, String
    attribute :created_at, DateTime
    attribute :updated_at, DateTime

    collection "sites"
    has_many :conversations, ->{ Conversation }

    def url_id
      slug
    end

  end
end
