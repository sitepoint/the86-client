module The86
  module Client

    class Error < StandardError
    end

    class ServerError < Error
    end

    class Unauthorized < Error
      def message
        "Unauthorized"
      end
    end

    class ValidationFailed < Error
    end

  end
end
