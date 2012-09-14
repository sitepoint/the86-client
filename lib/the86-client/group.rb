module The86::Client
  class Group < Resource

    attribute :id, Integer
    attribute :name, String
    attribute :slug, String
    attribute :created_at, DateTime
    attribute :updated_at, DateTime

    path "groups"
    has_many :conversations, ->{ Conversation }

    def url_id
      slug
    end

  end
end
