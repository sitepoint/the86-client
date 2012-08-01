module The86::Client
  class Post < Resource

    attribute :id, Integer
    attribute :content, String
    attribute :in_reply_to_id, Integer
    attribute :created_at, DateTime
    attribute :updated_at, DateTime

    path "posts"
    belongs_to :conversation
    has_one :user, ->{ User }
    has_one :in_reply_to, ->{ Post }

    def reply?
      !!in_reply_to_id
    end

    def reply(attributes)
      conversation.posts.create(
          attributes.merge(in_reply_to_id: id)
      )
    end

    def hide(attributes = {})
      self.oauth_token = attributes[:oauth_token]
      key = oauth_token ? :hidden_by_user : :hidden_by_site
      patch(key => true)
    end

  end
end
