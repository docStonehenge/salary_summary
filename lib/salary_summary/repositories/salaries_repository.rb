module SalarySummary
  module Repositories
    class SalariesRepository
      def initialize(client: Databases::MongoDB::Client.current_or_new_connection)
        @connection   = client
        @object_klass = Entities::Salary
      end

      def save(salary)
        @connection.insert_on(
          :salaries, period: salary.period, amount: salary.amount
        )
      end

      def find(id)
        load_salary(id) do
          query = get_entries({ _id: id }, {})

          raise Queries::EntityNotFoundError.new(
                  id: id, entity_name: @object_klass.name
                ) if query.empty?

          query.first
        end
      end

      def find_all(modifier: {}, sorted_by: {})
        get_entries(modifier, sorted_by).map do |entry|
          load_salary(entry.dig('_id')) { entry }
        end
      end

      def sum_by_amount
        aggregation = sum_aggregation
        aggregation.empty? ? 0 : aggregation.first.dig('sum')
      end

      private

      def get_entries(filter, sorted_by)
        @connection.find_on(:salaries, filter: filter, sort: sorted_by)
      end

      def load_salary(id)
        if (registered_salary = Persistence::UnitOfWork.current.get(@object_klass, id))
          return registered_salary
        end

        entry = yield

        Persistence::UnitOfWork.current.register_clean(@object_klass.new(entry))
      end

      def sum_aggregation
        @connection.aggregate_on(
          :salaries,
          { :$group => { _id: 'Sum', sum: { :$sum => '$amount' } } }
        ).entries
      end
    end
  end
end
