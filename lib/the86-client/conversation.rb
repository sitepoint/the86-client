module The86::Client
  class Conversation < Resource

    attribute :id, Integer
    attribute :created_at, DateTime
    attribute :updated_at, DateTime
    attribute :site, Site

    attribute :content, String # For creating new Conversation.

    def self.api_path(params = {})
      site = params.fetch(:site)
      "sites/#{site.slug}/conversations"
    end

    def posts=(posts)
      @_posts = posts.map do |post|
        if post.kind_of?(Post)
          post
        else
          Post.new(post)
        end
      end
    end

    def posts
      @_posts ||= Post.where(site: site, conversation: self)
    end

  end
end
