module SalarySummary
  module Repositories
    class SalariesRepository
      def initialize(client: Databases::MongoDB::Client.current_or_new_connection)
        @collection   = client.database_collection :salaries
        @object_klass = Entities::Salary
      end

      def save(salary)
        @collection.insert_one(period: salary.period, amount: salary.amount)
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
        aggregation = salaries_sum_aggregation
        aggregation.empty? ? 0 : aggregation.first.dig('sum')
      end

      private

      def get_entries(modifier, sorted_by)
        query = @collection.find(modifier)
        query = query.sort(sorted_by) unless sorted_by.empty?

        query.entries
      end

      def load_salary(id)
        if (registered_salary = Persistence::UnitOfWork.current.get(@object_klass, id))
          return registered_salary
        end

        entry = yield

        Persistence::UnitOfWork.current.register_clean(new_entity_for(entry))
      end

      def new_entity_for(entry)
        @object_klass.new(
          id: entry['_id'],
          period: entry['period'].to_date,
          amount: entry['amount']
        )
      end

      def salaries_sum_aggregation
        @collection.aggregate(
          [
            { :$group => { _id: 'Sum', sum: { :$sum => '$amount' } } }
          ]
        ).entries
      end
    end
  end
end
