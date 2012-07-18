module The86::Client
  class Conversation < Resource

    attribute :id, Integer
    attribute :created_at, DateTime
    attribute :updated_at, DateTime
    attribute :site, Site

    def self.api_path(params = {})
      "sites/#{params[:site].slug}/conversations"
    end

  end
end
