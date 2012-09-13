require_relative "spec_helper"

module The86::Client

  describe Like do

    let(:group) { The86::Client.group("test") }
    let(:group_url) { "https://example.org/api/v1/groups/test" }
    let(:post) { group.conversations.build(id: 1).posts.build(id: 2) }
    let(:likes_url) { "#{group_url}/conversations/1/posts/2/likes" }

    it "POSTs a new Like" do
      expect_request(
        url: likes_url,
        method: :post,
        status: 201,
        request_body: {},
        response_body: {user: {id: 1, name: "John Citizen"}},
        request_headers: {"Authorization" => "Bearer secret"},
      )

      post.likes.create(oauth_token: "secret")
    end

    it "GETs Likes" do
      expect_request(
        url: likes_url.sub("//", "//user:pass@"),
        method: :get,
        status: 200,
        response_body: [
          {user: {name: "John"}},
          {user: {name: "Alice"}},
        ],
      )

      post.likes.map { |l| l.user.name }.must_equal %w{John Alice}
    end

  end


end
