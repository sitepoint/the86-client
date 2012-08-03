module The86::Client
  class Conversation < Resource

    attribute :id, Integer
    attribute :content, String # For creating new Conversation.
    attribute :created_at, DateTime
    attribute :updated_at, DateTime

    path "conversations"
    belongs_to :site
    has_many :posts, ->{ Post }

    include CanBeHidden

  end
end
