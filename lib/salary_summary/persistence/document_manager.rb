module SalarySummary
  module Persistence
    class DocumentManager
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
        Repositories::Registry[entity_type].find(entity_id)
      end
    end
  end
end
