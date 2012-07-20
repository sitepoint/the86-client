require "virtus"

module The86
  module Client
    class Resource

      include Virtus

      # Assigned by Virtus constructor.
      attr_accessor :oauth_token

      # Parent resource, see belongs_to.
      attr_accessor :parent

      ##
      # Declarative API for subclasses.

      class << self

        def collection(collection_name)
          @collection_name = collection_name
        end

        def belongs_to(name)
          alias_method "#{name}=", :parent=
          alias_method name, :parent
        end

        def has_many(name, class_proc)
          define_method "#{name}=" do |items|
            (@_has_many ||= {})[name] = items
          end
          define_method name do
            has_many_reader(name, class_proc)
          end
        end

      end

      ##
      # Class methods.

      def self.collection_path(parent)
        [parent && parent.api_path, @collection_name].compact.join("/")
      end

      ##
      # Instance methods

      # The value of the identifier in the URL; numeric ID or string slug.
      def url_id
        id
      end

      def api_path
        "%s/%s" % [ self.class.collection_path(@parent), url_id ]
      end

      def save
        id ? save_existing : save_new
      end

      def sendable_attributes
        attributes.reject do |key, value|
          [:id, :created_at, :updated_at].include?(key) ||
            value.kind_of?(Resource) ||
            value.nil?
        end
      end

      def ==(other)
        attributes == other.attributes &&
          parent == other.parent
      end

      private

      def save_new
        self.attributes = connection.post(
          path: self.class.collection_path(@parent),
          data: sendable_attributes,
          status: 201
        )
      end

      def save_existing
        self.attributes = connection.patch(
          path: api_path,
          data: sendable_attributes,
          status: 200
        )
      end

      def connection
        Connection.new.tap do |c|
          c.prepend OauthBearerAuthorization, oauth_token if oauth_token
        end
      end

      def has_many_reader(name, class_proc)
        klass = class_proc.call
        ResourceCollection.new(
          connection,
          klass.collection_path(self),
          class_proc.call,
          self,
          (@_has_many || {})[name] || nil
        )
      rescue KeyError
        raise Error, "No reference to children :#{name}"
      end

    end
  end
end
