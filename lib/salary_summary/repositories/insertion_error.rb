module SalarySummary
  module Repositories
    class InsertionError < OperationError
      def operation_name
        :insertion
      end
    end
  end
end
