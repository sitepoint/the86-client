module The86::Client
  module CanBeHidden

    def hide(attributes = {})
      set_hidden(true, attributes)
    end

    def unhide(attributes = {})
      set_hidden(false, attributes)
    end

    private

    def set_hidden(hidden, attributes)
      self.oauth_token = attributes[:oauth_token]
      key = oauth_token ? :hidden_by_user : :hidden_by_site
      patch(key => hidden)
    end

  end
end
