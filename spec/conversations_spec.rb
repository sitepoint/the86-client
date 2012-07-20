require_relative "spec_helper"

module The86::Client

  describe "Conversations" do

    describe "listing conversations" do
      it "returns empty array for site without conversations" do
        expect_get_conversations(response_body: [])
        site.conversations.to_a.size.must_equal 0
      end

      it "returns collection of conversations" do
        expect_get_conversations(response_body: [{id: 10}, {id: 12}])
        conversations = site.conversations
        conversations.to_a.size.must_equal 2
        c = conversations.first
        c.must_be_instance_of Conversation
        c.id.must_equal 10
        c.site.must_equal site
      end
    end

    describe "creating conversations" do
      it "posts and returns a conversation with the first post content" do
        expect_request(
          url: "https://example.org/api/v1/sites/test/conversations",
          method: :post,
          status: 201,
          request_body: {content: "A new conversation."},
          response_body: {id: 2, posts: [{id: 5, content: "A new conversation."}]},
          request_headers: {"Authorization" => "Bearer secrettoken"},
        )

        c = site.conversations.create(
          content: "A new conversation.",
          oauth_token: "secrettoken",
        )

        c.id.must_equal 2
        posts = c.posts
        posts.to_a.length.must_equal 1
        posts[0].content.must_equal "A new conversation."
      end
    end

    def site
      The86::Client.site("test")
    end

    def expect_get_conversations(options)
      expect_request({
        url: "https://user:pass@example.org/api/v1/sites/test/conversations",
        method: :get,
        status: 200,
      }.merge(options))
    end

  end

end
