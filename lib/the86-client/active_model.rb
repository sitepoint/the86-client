# Patches The86::Client::Resource to implement enough of
# ActiveModel's interface to act as a form object.
# Depends on ActiveModel being provided externally.

module The86
  module Client
    class Resource

      extend ActiveModel::Naming

      include ActiveModel::Validations

      # Model name relative to The86::Client namespace.
      # Names form fields like post[...] instead of the86_client_post[...].
      def self.model_name
        ActiveModel::Name.new(self, The86::Client)
      end

      def to_model
        self
      end

      def persisted?
        !!id
      end

      def to_key
        nil
      end

      def to_param
        url_id
      end

    end
  end
end
