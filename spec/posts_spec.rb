require_relative "spec_helper"

module The86::Client

  describe Post do

    describe "replying to a post" do
      it "sends in_reply_to_id" do
        expect_request(
          url: "https://example.org/api/v1/sites/test/conversations/32/posts",
          method: :post,
          status: 201,
          request_body: {content: "Hi!", in_reply_to_id: 64},
          response_body: {
            id: 96, content: "Hi!", in_reply_to_id: 64, in_reply_to: {
              id: 64,
              content: "Hello!",
              user: {
                id: 128,
                name: "Johnny Original"
              }
            }
          },
          request_headers: {"Authorization" => "Bearer SecretTokenHere"},
        )
        post = original_post.reply(
          content: "Hi!",
          oauth_token: "SecretTokenHere",
        )
        post.conversation.id.must_equal conversation.id
        post.in_reply_to_id.must_equal original_post.id
        post.in_reply_to.user.name.must_equal "Johnny Original"
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
          request_headers: {"Authorization" => "Bearer SecretTokenHere"},
        )
        post = conversation.posts.create(
          content: "+1",
          oauth_token: "SecretTokenHere",
        )
        post.conversation.id.must_equal conversation.id
        post.in_reply_to_id.must_equal nil
        post.content.must_equal "+1"
      end
    end

    describe "#hide" do
      let(:post) { conversation.posts.build(id: 2) }
      let(:url) { "https://example.org/api/v1/sites/test/conversations/32/posts/2" }
      it "patches the post as hidden_by_site when no oauth_token" do
        expect_request(
          url: url.sub("https://", "https://user:pass@"),
          method: :patch,
          status: 200,
          request_body: {hidden_by_site: true},
          response_body: {id: 2, hidden_by_site: true},
        )
        post.hide
      end
      it "patches the post as hidden_by_user when oauth_token present" do
        expect_request(
          url: url,
          method: :patch,
          status: 200,
          request_body: {hidden_by_user: true},
          request_headers: {"Authorization" => "Bearer secret"},
          response_body: {id: 2, hidden_by_site: true},
        )
        post.hide(oauth_token: "secret")
      end
    end

    def original_post
      Post.new(id: 64, conversation: conversation, content: "Hello!")
    end

    def conversation
      Conversation.new(id: 32, site: site)
    end

    def site
      The86::Client.site("test")
    end

  end

end
