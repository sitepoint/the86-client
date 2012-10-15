module The86::Client
  class Metadatum < Resource

    attribute :id, Integer
    attribute :key, String
    attribute :value, String
    attribute :created_at, DateTime
    attribute :updated_at, DateTime

  end
end
