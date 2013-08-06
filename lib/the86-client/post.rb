module The86::Client
  class Post < Resource

    attribute :id, Integer
    attribute :content, String
    attribute :content_html, String
    attribute :in_reply_to_id, Integer
    attribute :is_original, Boolean
    attribute :created_at, DateTime
    attribute :original_created_at, DateTime
    attribute :updated_at, DateTime

    path "posts"
    belongs_to :conversation
    has_one :user, ->{ User }
    has_one :in_reply_to, ->{ Post }
    has_many :likes, ->{ Like }

    include CanBeHidden

    def reply?
      !!in_reply_to_id
    end

    def reply(attributes)
      conversation.posts.create(
          attributes.merge(in_reply_to_id: id)
      )
    end

  end
end
