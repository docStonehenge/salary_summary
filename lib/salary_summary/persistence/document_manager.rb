module SalarySummary
  module Persistence
    class DocumentManager
      extend Forwardable

      def_delegators :@unit_of_work, :detach, :clear

      def initialize
        connection    = Databases::MongoDB::Client.current_or_new_connection
        @id_generator = connection.id_generator

        @unit_of_work = begin
                          UnitOfWork.current
                        rescue UnitOfWorkNotStartedError
                          UnitOfWork.new_current
                        end
      end

      def find(entity_type, entity_id)
        repository_for(entity_type).find(entity_id)
      end

      def find_all(entity_type, modifier: {}, sorted_by: {})
        repository_for(entity_type).find_all(
          modifier: modifier, sorted_by: sorted_by
        )
      end

      def persist(entity)
        entity.id = @id_generator.generate if entity.id.to_s.empty?
        @unit_of_work.register_new entity
      end

      def remove(entity)
        @unit_of_work.register_removed entity
      end

      private

      def repository_for(entity_type)
        Repositories::Registry[entity_type]
      end
    end
  end
end
