module SalarySummary
  module Repositories
    module Base
      # Initializes an instance of repository, receiving a call to set new or fetch
      # current connection from chosen database.
      # Determines <tt>collection_name</tt> and <tt>entity_klass</tt> attributes
      # based on repository classes that include this behavior.
      def initialize(client: Databases::MongoDB::Client.current_or_new_connection)
        @connection      = client
        @collection_name = collection_name
        @entity_klass    = entity_klass
      end

      def find(id)
        load_entity(id) do
          query = get_entries({ _id: id }, {})

          raise Queries::EntityNotFoundError.new(
                  id: id, entity_name: @entity_klass.name
                ) if query.empty?

          query.first
        end
      end

      def find_all(modifier: {}, sorted_by: {})
        get_entries(modifier, sorted_by).map do |entry|
          load_entity(entry.dig('_id')) { entry }
        end
      end

      def insert(entity)
        unless entity.is_a? @entity_klass
          raise ArgumentError,
                "Entity to be inserted must be of class set on "\
                "repository as #entity_klass: #{@entity_klass}. "\
                "This repository cannot operate on instances of #{entity.class}."
        end

        @connection.insert_on(@collection_name, entity.to_mongo_document)
      end

      def aggregate
        @connection.aggregate_on(@collection_name, *(yield [])).entries
      end

      private

      def get_entries(filter, sorted_by)
        @connection.find_on(
          @collection_name, filter: filter.to_mongo_value, sort: sorted_by
        )
      end

      def load_entity(id)
        if (loaded_entity = Persistence::UnitOfWork.current.get(@entity_klass, id))
          return loaded_entity
        end

        entry = yield

        Persistence::UnitOfWork.current.register_clean(@entity_klass.new(entry))
      end
    end
  end
end
