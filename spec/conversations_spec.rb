require_relative "spec_helper"

module The86::Client

  describe "Conversations" do

    let(:site) { The86::Client.site("test") }
    let(:site_url) { "https://example.org/api/v1/sites/test" }
    let(:conversations_url) { "#{site_url}/conversations" }

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

      it "sends posts_since parameter" do
        expect_get_conversations(
          response_body: [{id: 10}, {id: 12}],
          parameters: {posts_since: "time"}
        )
        conversations = site.conversations.with_parameters(posts_since: "time")
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
          url: conversations_url,
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

    describe "finding a conversation" do
      it "gets the conversation, loads data into the resource" do
        expect_request(
          url: "https://user:pass@example.org/api/v1/sites/test/conversations/4",
          method: :get,
          status: 200,
          response_body: {id: 4, posts: [{id: 8, content: "A post."}]},
        )
        c = site.conversations.find(4)
        c.id.must_equal 4
        c.posts.first.content.must_equal "A post."
      end
    end

    describe "hiding and unhiding a conversation" do
      let(:conversation) { site.conversations.build(id: 2) }
      let(:oauth_url) { "#{conversations_url}/2" }
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
        it "patches the conversation as hidden_by_site when no oauth_token" do
          expect_request(expectation(basic_auth_url, hidden_by_site: true))
          conversation.hide

          expect_request(expectation(basic_auth_url, hidden_by_site: false))
          conversation.unhide
        end
      end
      describe "with oauth" do
        let(:headers) { {"Authorization" => "Bearer secret"} }
        it "patches the conversation as hidden_by_user when oauth_token present" do
          expect_request(expectation(oauth_url, hidden_by_user: true))
          conversation.hide(oauth_token: "secret")

          expect_request(expectation(oauth_url, hidden_by_user: false))
          conversation.unhide(oauth_token: "secret")
        end
      end
    end

    def expect_get_conversations(options)
      expect_request({
        url: conversations_url.sub("//", "//user:pass@"),
        method: :get,
        status: 200,
      }.merge(options))
    end

  end

end
