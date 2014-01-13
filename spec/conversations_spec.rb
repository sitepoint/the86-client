require_relative "spec_helper"

module The86::Client

  describe "Conversations" do

    let(:group) { The86::Client.group("test") }
    let(:group_url) { "https://example.org/api/v1/groups/test" }
    let(:conversations_url) { "#{group_url}/conversations" }

    describe "listing conversations" do
      it "returns empty array for group without conversations" do
        expect_get_conversations(response_body: [])
        group.conversations.to_a.size.must_equal 0
      end

      it "returns collection of conversations" do
        expect_get_conversations(response_body: [{id: 10}, {id: 12}])
        conversations = group.conversations
        conversations.to_a.size.must_equal 2
        c = conversations.first
        c.must_be_instance_of Conversation
        c.id.must_equal 10
        c.group.must_equal group
      end

      # This test is specifically for a breakage of Addressable::URI that occurs
      # with nested hashes when version > 2.2.7
      it "does not fail when specifying metadata" do
        meta_hash = { metadata: [ {key: "key1", value: "value1"}, {key: "key2", value: "value2"}] }
        expect_get_conversations(response_body: [{id: 10}, {id: 12}], parameters: meta_hash)
        conversations = group.conversations.with_parameters(meta_hash)
        conversations.to_a
      end

      it "sends posts_since parameter" do
        expect_get_conversations(
          response_body: [{id: 10}, {id: 12}],
          parameters: {posts_since: "time"}
        )
        conversations = group.conversations.with_parameters(posts_since: "time")
        conversations.to_a.size.must_equal 2
        c = conversations.first
        c.must_be_instance_of Conversation
        c.id.must_equal 10
        c.group.must_equal group
      end

      it "handles pagination headers" do
        url = "#{conversations_url}?limit=2"
        next_url = "#{url}&bumped_before=timestamp"
        expect_get_conversations(
          url: basic_auth_url(url),
          response_body: [{id: 1}, {id: 2}],
          response_headers: {"Link" => %{<#{next_url}>; rel="next"}}
        )
        expect_get_conversations(
          url: basic_auth_url(next_url),
          response_body: [{id: 3}, {id: 4}],
        )
        page1 = group.conversations.with_parameters(limit: 2)
        page1.more?.must_equal true

        page2 = page1.more
        page2.more?.must_equal false

        page1.map(&:id).must_equal([1,2])
        page2.map(&:id).must_equal([3,4])
      end

      it "allows pagination parameters to be fetched and set" do
        url = "#{conversations_url}?limit=2"
        next_url = "#{url}&bumped_before=timestamp"
        expect_get_conversations(
          url: basic_auth_url(url),
          response_body: [{id: 1}, {id: 2}],
          response_headers: {"Link" => %{<#{next_url}>; rel="next"}}
        )

        expect_get_conversations(
          url: basic_auth_url(next_url),
          response_body: [{id: 3}, {id: 4}],
        )

        # Emulate parameters being serialized & stored for a later request.
        page1 = group.conversations.with_parameters(limit: 2)
        parameters = JSON.parse(JSON.generate(page1.more.parameters))
        page2 = group.conversations.with_parameters(parameters)

        parameters.must_equal("limit" => "2", "bumped_before" => "timestamp")

        page1.more?.must_equal true
        page2.more?.must_equal false

        page1.map(&:id).must_equal([1,2])
        page2.map(&:id).must_equal([3,4])
      end
    end

    describe "creating conversations" do
      it "posts and returns a conversation with the first post content" do

        c = group.conversations.build(
          content: "A new conversation.",
          oauth_token: "secrettoken",
        )

        expect_request(
          url: conversations_url,
          method: :post,
          status: 201,
          request_body: {content: "A new conversation.", metadata: c.metadata.to_s},
          response_body: {id: 2, posts: [{id: 5, content: "A new conversation."}]},
          request_headers: {"Authorization" => "Bearer secrettoken"},
        )

        c.save

        c.id.must_equal 2
        posts = c.posts
        posts.to_a.length.must_equal 1
        posts[0].content.must_equal "A new conversation."
      end
    end

    describe "finding a conversation" do
      it "gets the conversation, loads data into the resource" do
        expect_request(
          url: basic_auth_url("https://example.org/api/v1/groups/test/conversations/4"),
          method: :get,
          status: 200,
          response_body: {id: 4, posts: [{id: 8, content: "A post."}]},
        )
        c = group.conversations.find(4)
        c.id.must_equal 4
        c.posts.first.content.must_equal "A post."
      end

      it "raises NotFoundError when the conversation does not exist" do
        expect_request(
          url: basic_auth_url("https://example.org/api/v1/groups/test/conversations/9999"),
          method: :get,
          status: 404,
          response_body: Hash.new
        )
        assert_raises NotFoundError do
          group.conversations.find(9999)
        end
      end
    end

    describe "hiding and unhiding a conversation" do
      let(:conversation) { group.conversations.build(id: 2) }
      let(:user_auth_url) { "#{conversations_url}/2" }
      let(:group_auth_url) { user_auth_url.sub("//", "//user:pass@") }
      let(:group_auth_url) { basic_auth_url(user_auth_url) }
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
        it "patches the conversation as hidden_by_group when no oauth_token" do
          expect_request(expectation(group_auth_url, hidden_by_group: true))
          conversation.hide

          expect_request(expectation(group_auth_url, hidden_by_group: false))
          conversation.unhide
        end
      end
      describe "with oauth" do
        let(:headers) { {"Authorization" => "Bearer secret"} }
        it "patches the conversation as hidden_by_user when oauth_token present" do
          expect_request(expectation(user_auth_url, hidden_by_user: true))
          conversation.hide(oauth_token: "secret")

          expect_request(expectation(user_auth_url, hidden_by_user: false))
          conversation.unhide(oauth_token: "secret")
        end
      end
    end

    describe "muting a conversation" do
      let(:conversation) { group.conversations.build(id: 2) }
      describe "without oauth" do
        it "raises an error" do
          ->{ conversation.mute }.must_raise Error
        end
      end
      describe "with oauth" do
        def expectation(url, hidden_param={})
          {
            url: url,
            method: :post,
            status: 200,
            request_body: hidden_param,
            request_headers: headers,
            response_body: {id: 2}.merge(hidden_param),
          }
        end
        let(:mute_url) { "#{conversations_url}/2/mute" }
        let(:headers) { {"Authorization" => "Bearer secret"} }
        it "mutes the conversation" do
          expect_request(expectation(mute_url))
          conversation.mute(oauth_token: "secret")
        end
      end
    end

    def expect_get_conversations(options)
      expect_request({
        url: basic_auth_url(conversations_url),
        method: :get,
        status: 200,
      }.merge(options))
    end

    def basic_auth_url(url)
      url.sub("//", "//user:pass@")
    end
  end

end
