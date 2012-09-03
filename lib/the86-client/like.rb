module The86::Client
  class Like < Resource

    attribute :id, Integer

    path "likes"
    belongs_to :post
    has_one :user, ->{ User }

  end
end
