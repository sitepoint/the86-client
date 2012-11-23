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

    it "DELETEs a metadatum" do
      metadata_auth_url = metadata_url.sub("//", "//user:pass@")

      expect_request(
        url: metadata_auth_url,
        method: :get,
        status: 200,
        response_body: [
          { id: "1", key: "tag", value: "foo" },
          { id: "2", key: "tag", value: "bar" },
        ],
      )

      m = conversation.metadata

      expect_request(
        url: "#{metadata_auth_url}/#{m.first.id}",
        method: :delete,
        status: 204)
    
      m.first.delete!
    end
  end

  describe Conversation do
    let(:group) { The86::Client.group("test") }
    let(:group_url) { "https://example.org/api/v1/groups/test" }
    let(:conversation) { group.conversations.build(id: 1) }
    let(:metadata_url) { "#{group_url}/conversations/1/metadata" }
    
    it "PATCHes metadata for a given key" do
      metadata_auth_url = metadata_url.sub("//", "//user:pass@")

      expect_request(
        url: metadata_auth_url,
        method: :patch,
        status: 204,
        request_body: { key: ["a", "b", "c"] },
      )
      
      conversation.set_metadata({ key: ["a", "b", "c"]})
    end
    
    it "clears a key by sending an empty array" do
      metadata_auth_url = metadata_url.sub("//", "//user:pass@")

      expect_request(
        url: metadata_auth_url,
        method: :patch,
        status: 204,
        request_body: { key: [] },
      )
      
      conversation.set_metadata({key: []})
    end
  end
end
