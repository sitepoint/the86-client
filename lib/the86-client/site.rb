module The86::Client
  class Site < Resource

    attribute :id, Integer
    attribute :slug, String
    attribute :created_at, DateTime
    attribute :updated_at, DateTime

    def conversations
      Conversation.where(site: self)
    end

  end
end
