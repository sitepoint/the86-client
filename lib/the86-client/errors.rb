module The86
  module Client

    class Error < StandardError
    end

    class ServerError < Error
    end

    class NotFoundError < Error
    end
    
    class Unauthorized < Error
      def message
        "Unauthorized"
      end
    end

    class ValidationFailed < Error
    end

    class PaginationError < Error
    end

  end
end
