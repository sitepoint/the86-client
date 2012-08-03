require_relative "spec_helper"

module The86::Client

  describe Post do

    let(:site) { The86::Client.site("test") }
    let(:conversation) { Conversation.new(id: 32, site: site) }
    let(:original_post) do
      Post.new(id: 64, conversation: conversation, content: "Hello!")
    end
    let(:site_url) { "https://example.org/api/v1/sites/test" }
    let(:conversation_url) { "#{site_url}/conversations/32" }
    let(:posts_url) { "#{conversation_url}/posts" }

    describe "replying to a post" do
      it "sends in_reply_to_id" do
        expect_request(
          url: posts_url,
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
          url: posts_url,
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

    describe "hiding and unhiding posts" do
      let(:post) { conversation.posts.build(id: 2) }
      let(:oauth_url) { "#{posts_url}/2" }
      let(:basic_auth_url) { oauth_url.sub("//", "//user:pass@") }
      let(:headers) { Hash.new }
      def expectation(url, hidden_param)
        {
          url: url,
          method: :patch,
          status: 200,
          request_body: hidden_param,
          request_headers: headers,
          response_body: {id: 2}.merge(hidden_param),
        }
      end
      describe "without oauth" do
        it "patches the post as hidden_by_site when no oauth_token" do
          expect_request(expectation(basic_auth_url, hidden_by_site: true))
          post.hide

          expect_request(expectation(basic_auth_url, hidden_by_site: false))
          post.unhide
        end
      end
      describe "with oauth" do
        let(:headers) { {"Authorization" => "Bearer secret"} }
        it "patches the post as hidden_by_user when oauth_token present" do
          expect_request(expectation(oauth_url, hidden_by_user: true))
          post.hide(oauth_token: "secret")

          expect_request(expectation(oauth_url, hidden_by_user: false))
          post.unhide(oauth_token: "secret")
        end
      end
    end

  end

end
