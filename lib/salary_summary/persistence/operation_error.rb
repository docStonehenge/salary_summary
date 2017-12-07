module SalarySummary
  module Persistence
    # Custom exception class that provides a wrapper around database operation errors.
    # Receives a message on constructor, which will be used as a +reason+ for why that operation failed
    # in the exception message.
    #
    # Examples
    #
    #
    class OperationError < StandardError
      def initialize(message)
        super("The database operation has failed. Reason: '#{message}'")
      end
    end
  end
end
