module The86::Client
  class ConversationMetadatum < Metadatum

    belongs_to :conversation
    path "metadata"

  end
end
