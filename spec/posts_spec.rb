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

    describe "#user" do
      let(:post) { Post.new(id: 1, user: {id: 2, name: "John Citizen"}) }
      it "returns instance of The86::Client::User" do
        post.user.must_be_instance_of(The86::Client::User)
      end
      it "contains the user details" do
        post.user.name.must_equal "John Citizen"
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
