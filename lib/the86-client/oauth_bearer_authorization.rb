module The86::Client

  # A Faraday middleware which adds or overwrites the
  # Authorization header with an OAuth2 bearer token.
  # See: http://tools.ietf.org/html/draft-ietf-oauth-v2-bearer-22
  class OauthBearerAuthorization < Faraday::Middleware

    AUTH_HEADER = "Authorization"

    def initialize(app, token)
      super(app)
      @token = token
    end

    def call(env)
      env[:request_headers][AUTH_HEADER] = "Bearer #{@token}"
      @app.call(env)
    end

  end
end
