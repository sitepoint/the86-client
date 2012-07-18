module The86::Client
  class Post < Resource

    attribute :id, Integer
    attribute :content, String
    attribute :in_reply_to, Integer
    attribute :created_at, DateTime
    attribute :updated_at, DateTime

    attribute :conversation, Object

    def self.api_path(params = {})
      conversation = params.fetch(:conversation)
      "sites/%s/conversations/%d/posts" % [
        conversation.site.slug,
        conversation.id
      ]
    end

    def reply(attributes)
      conversation.posts.create(
        attributes.merge(in_reply_to: id)
      )
    end

  end
end
