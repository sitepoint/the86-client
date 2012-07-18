require_relative "spec_helper"

module The86::Client

  describe Post do

    describe "replying to a post" do
      it "sends in_reply_to" do
        expect_request(
          url: "https://example.org/api/v1/sites/test/conversations/32/posts",
          method: :post,
          status: 201,
          request_body: {content: "Hi!", in_reply_to: 64},
          response_body: {id: 96, content: "Hi!", in_reply_to: 64},
        )
        post = original_post.reply(content: "Hi!")
        post.conversation.id.must_equal conversation.id
        post.in_reply_to.must_equal original_post.id
        post.content.must_equal "Hi!"
      end
    end

    describe "following up to a conversation" do
      it "creates new Post in the Conversation" do
        expect_request(
          url: "https://example.org/api/v1/sites/test/conversations/32/posts",
          method: :post,
          status: 201,
          request_body: {content: "+1"},
          response_body: {id: 96, content: "+1"},
        )
        post = conversation.posts.create(content: "+1")
        post.conversation.id.must_equal conversation.id
        post.in_reply_to.must_equal nil
        post.content.must_equal "+1"
      end
    end

    def original_post
      Post.new(id: 64, conversation: conversation, content: "Hello!")
    end

    def conversation
      Conversation.new(id: 32, site: site)
    end

    def site
      Site.new(slug: "test")
    end

  end

end
