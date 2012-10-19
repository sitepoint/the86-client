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

    def mute(attributes={})
      unless attributes[:oauth_token]
        raise Error, "Conversations must be hidden by a user"
      end
      self.oauth_token = attributes[:oauth_token]
      connection.post(
        path: resource_path << "/mute",
        data: sendable_attributes,
        status: 200
      ).data
    end

  end
end
