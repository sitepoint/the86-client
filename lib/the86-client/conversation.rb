module The86::Client
  class Conversation < Resource

    attribute :id, Integer
    attribute :content, String # For creating new Conversation.
    attribute :bumped_at, DateTime
    attribute :created_at, DateTime
    attribute :original_created_at, DateTime
    attribute :updated_at, DateTime

    path "conversations"
    belongs_to :group
    has_many :posts, ->{ Post }
    has_many :metadata, ->{ ConversationMetadatum }

    include CanBeHidden

  end
end
