module SalarySummary
  module Repositories
    class UpdateError < OperationError
      def operation_name
        :update
      end
    end
  end
end
