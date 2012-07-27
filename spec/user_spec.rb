require_relative "spec_helper"

module The86::Client
  describe User do

    it "stores name" do
      User.new(name: "John").name.must_equal "John"
    end

    it "can store access tokens passed into constructor" do
      u = User.new(access_tokens: [{token: "one"}, {token: "two"}])
      u.access_tokens.first.must_be_instance_of AccessToken
      u.access_tokens.first.token.must_equal "one"
      u.access_tokens[1].token.must_equal "two"
    end

  end
end
