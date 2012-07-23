module The86::Client
  class Post < Resource

    attribute :id, Integer
    attribute :content, String
    attribute :in_reply_to, Integer
    attribute :created_at, DateTime
    attribute :updated_at, DateTime

    path "posts"
    belongs_to :conversation
    has_one :user, ->{ User }

    def reply?
      !!in_reply_to
    end

    def reply(attributes)
      conversation.posts.create(
        attributes.merge(in_reply_to: id)
      )
    end

  end
end
