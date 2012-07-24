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
  end
end
