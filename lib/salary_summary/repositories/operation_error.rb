module SalarySummary
  module Repositories
    # Custom exception class that provides a wrapper around database operation errors
    # called within repositories.
    # Receives operation and message on constructor, which will be used as a
    # +reason+ to determine which operation failed in the exception message.
    class OperationError < StandardError
      def initialize(operation, message)
        super("Error on #{operation} operation. Reason: '#{message}'")
      end
    end
  end
end
