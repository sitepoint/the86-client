require_relative "spec_helper"

module The86::Client

  describe ConversationMetadatum do

    let(:group) { The86::Client.group("test") }
    let(:group_url) { "https://example.org/api/v1/groups/test" }
    let(:conversation) { group.conversations.build(id: 1) }
    let(:metadata_url) { "#{group_url}/conversations/1/metadata" }

    it "POSTs a new metadatum" do
      expect_request(
        url: metadata_url,
        method: :post,
        status: 201,
        request_body: { key: "foo", value: "bar" },
        response_body: { key: "foo", value: "bar" },
        request_headers: {"Authorization" => "Bearer secret"},
      )

      m = conversation.metadata.create(key: "foo", value: "bar", oauth_token: "secret")

      m.must_be_instance_of ConversationMetadatum
      m.key.must_equal "foo"
      m.value.must_equal "bar"
    end

    it "GETs metadata" do
      expect_request(
        url: metadata_url.sub("//", "//user:pass@"),
        method: :get,
        status: 200,
        response_body: [
          { key: "tag", value: "foo" },
          { key: "tag", value: "bar" },
        ],
      )

      conversation.metadata.map(&:value).must_equal %w{ foo bar }
    end

  end


end
