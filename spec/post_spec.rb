require_relative "spec_helper"
require "the86-client/post"

module The86::Client
  describe Post do
    describe "#reply?" do
      it "is true when in_reply_to is present" do
        Post.new(in_reply_to: 32).reply?.must_equal true
      end
      it "is false when in_reply_to is not present" do
        Post.new(in_reply_to: nil).reply?.must_equal false
      end
    end
  end
end
