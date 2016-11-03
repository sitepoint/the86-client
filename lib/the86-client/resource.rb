require "virtus"

module The86
  module Client
    class Resource

      include Virtus.model

      # Assigned by Virtus constructor.
      attr_accessor :oauth_token

      # Parent resource, see belongs_to.
      attr_accessor :parent

      ##
      # Declarative API for subclasses.

      class << self

        # The path component for the collection, e.g. "discussions"
        def path(path)
          @path = path
        end

        # The name of the parent resource attribute.
        # e.g: belongs_to :group
        def belongs_to(name)
          alias_method "#{name}=", :parent=
          alias_method name, :parent
        end

        # The name of a child collection.
        def has_many(name, class_proc)
          define_method "#{name}=" do |items|
            (@_has_many ||= {})[name] = items
          end
          define_method name do
            has_many_reader(name, class_proc)
          end
        end

        def has_one(name, class_proc)
          define_method "#{name}=" do |instance|
            (@_has_one ||= {})[name] = instance
          end
          define_method name do
            has_one_reader(name, class_proc)
          end
        end

        # Allow nested attribute creation
        def accepts_nested_attributes_for(name)
          attribute name, Array
        end

      end

      ##
      # Class methods.

      def self.collection_path(parent)
        [parent && parent.resource_path, @path].compact.join("/")
      end

      ##
      # Instance methods

      # The value of the identifier in the URL; numeric ID or string slug.
      # TODO: see ResourceCollection#find.
      def url_id
        id
      end

      def resource_path
        "%s/%s" % [ self.class.collection_path(@parent), url_id ]
      end

      # TODO: The parent resource should be appropriately updated that the resource no longer exists
      def delete!
        connection.delete(
          path: resource_path,
          status: 204
        ).data
      end

      def save
        id ? save_existing : save_new
      end

      def load
        self.attributes = connection.get(
          path: resource_path,
          status: 200
        ).data
        self
      end

      def patch(attributes)
        self.attributes = connection.patch(
          path: resource_path,
          data: attributes,
          status: 200
        ).data
      end

      def sendable_attributes
        sa = attributes.reject do |key, value|
          [:id, :created_at, :updated_at].include?(key) ||
            value.kind_of?(Resource) ||
            value.nil?
        end

        sa[:metadata] = attributes[:metadata].as_json
        sa
      end

      def ==(other)
        other.respond_to?(:attributes) &&
          other.respond_to?(:parent) &&
          attributes == other.attributes &&
          parent == other.parent
      end

      private

      def save_new
        self.attributes = connection.post(
          path: self.class.collection_path(@parent),
          data: sendable_attributes,
          status: 201
        ).data
      end

      def save_existing
        self.attributes = connection.patch(
          path: resource_path,
          data: sendable_attributes,
          status: 200
        ).data
      end

      def connection
        Connection.new.tap do |c|
          c.prepend OauthBearerAuthorization, oauth_token if oauth_token
        end
      end

      def has_many_reader(name, class_proc)
        variable_name = "@_has_many_reader_#{name}"
        instance_variable_get(variable_name) ||
          instance_variable_set(variable_name, (
            klass = class_proc.call
            ResourceCollection.new(
              connection,
              klass.collection_path(self),
              class_proc.call,
              self,
              (@_has_many || {})[name] || nil
            )
          )
        )
      rescue KeyError
        raise Error, "No reference to children :#{name}"
      end

      def has_one_reader(name, class_proc)
        klass = class_proc.call
        record = (@_has_one || {}).fetch(name)
        if record.is_a?(Resource)
          record
        else
          @_has_one[name] = klass.new(record)
        end
      rescue KeyError
        raise Error, "No reference to child :#{name}"
      end

    end
  end
end
