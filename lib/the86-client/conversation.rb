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

    accepts_nested_attributes_for :metadata

    include CanBeHidden

    def mute(attributes={})
      unless attributes[:oauth_token]
        raise Error, "Conversations must be hidden by a user"
      end
      self.oauth_token = attributes[:oauth_token]
      connection.post(
        path: resource_path << "/mute",
        data: sendable_attributes,
        status: 204
      ).data
    end

    def set_metadata(attributes={})
      connection.patch(
        path: resource_path << "/metadata",
        data: attributes,
        status: 204
      )
    end
  end
end
