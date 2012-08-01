require_relative "spec_helper"
require "the86-client/post"

module The86::Client
  describe Post do
    describe "#reply?" do
      it "is true when in_reply_to_id is present" do
        Post.new(in_reply_to_id: 32).reply?.must_equal true
      end
      it "is false when in_reply_to_id is not present" do
        Post.new(in_reply_to_id: nil).reply?.must_equal false
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
  end
end
