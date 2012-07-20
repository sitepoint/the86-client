require_relative "spec_helper"

module The86::Client
  describe OauthBearerAuthorization do

    it "sets Authorization header, calls delegate" do
      env = {request_headers: {}}

      app = MiniTest::Mock.new
      app.expect(:call, nil, [env])

      OauthBearerAuthorization.new(app, "secret").call(env)

      env[:request_headers]["Authorization"].must_equal "Bearer secret"
      app.verify
    end

  end
end
