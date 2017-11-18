module SalarySummary
  module Persistence
    class UnitOfWork
      # Sets a new instance of UnitOfWork as <tt>current_uow</tt> on running thread.
      # If a current UnitOfWork is present, uses entity registry set on it; if not,
      # initializes a UnitOfWork with a new Entities::Registry.
      def self.new_current
        self.current = new(
          begin
            current.clean_entities
          rescue UnitOfWorkNotStartedError
            Entities::Registry.new
          end
        )
      end

      # Sets an instance of UnitOfWork as <tt>current_uow</tt> on running thread.
      def self.current=(unit_of_work)
        Thread.current.thread_variable_set(:current_uow, unit_of_work)
      end

      # Returns <tt>current_uow</tt> UnitOfWork on running thread.
      # Raises UnitOfWorkNotStartedError when no instance is found on thread.
      def self.current
        Thread.current.thread_variable_get(:current_uow).tap do |uow|
          raise UnitOfWorkNotStartedError unless uow
        end
      end

      attr_reader :clean_entities

      # Initializes an instance with three new Set objects and an Entities::Registry
      def initialize(entity_registry)
        @clean_entities   = entity_registry
        @new_entities     = Set.new
        @changed_entities = Set.new
        @removed_entities = Set.new
      end

      # Returns +entity+ found by <tt>entity_class</tt> and <tt>entity_id</tt>
      # on <tt>clean_entities</tt> list or nil if no entity is found.
      def get(entity_class, entity_id)
        @clean_entities.get(entity_class, entity_id)
      end

      # Registers <tt>entity</tt> on clean entities map, avoiding duplicates.
      # Ingores entities without IDs, calls registration even if present on other lists.
      # Returns the +entity+ added or +nil+ if entity has no ID or it's a duplicate.
      #
      # Examples
      #
      #   register_clean(SalarySummary::Entities::Salary.new(id: 123))
      #   # => <SalarySummary::Entities::Salary:0x007f8b1a9028b8 @id=123, @amount=nil, @period=nil>
      def register_clean(entity)
        register_on(
          @clean_entities, entity,
          ignore: [@new_entities, @changed_entities, @removed_entities]
        )
      end

      # Registers <tt>entity</tt> on new entities list and on clean entities, avoiding duplicates.
      # Ingores entities without IDs and if present on other lists.
      # Returns the +set+ with entity added or +nil+ if entity has no ID or it's a duplicate.
      #
      # Examples
      #
      #   register_new(SalarySummary::Entities::Salary.new(id: 123))
      #   # => #<Set: {#<SalarySummary::Entities::Salary:0x007f8b1a9028b8 @id=123, @amount=nil, @period=nil>}>
      def register_new(entity)
        register_on @clean_entities, entity
        register_on @new_entities, entity
      end

      # Registers <tt>entity</tt> on changed entities list, avoiding duplicates.
      # Ingores entities without IDs and if present on other lists.
      # Returns the +set+ with entity added or +nil+ if entity has no ID or it's a duplicate.
      #
      # Examples
      #
      #   register_changed(SalarySummary::Entities::Salary.new(id: 123))
      #   # => #<Set: {#<SalarySummary::Entities::Salary:0x007f8b1a9028b8 @id=123, @amount=nil, @period=nil>}>
      def register_changed(entity)
        register_on @changed_entities, entity
      end

      # Tries to remove <tt>entity</tt> from <tt>changed_entities</tt>, registers it
      # on removed entities list, removes from <tt>clean_entities</tt>, avoiding duplicates.
      # If it can remove from <tt>new_entities</tt>, it doesn't register on <tt>removed_entities</tt>.
      # Ingores entities without IDs.
      # Returns the +set+ with entity added or +nil+ if entity has no ID or it's a duplicate.
      #
      # Examples
      #
      #   register_removed(SalarySummary::Entities::Salary.new(id: 123))
      #   # => #<Set: {#<SalarySummary::Entities::Salary:0x007f8b1a9028b8 @id=123, @amount=nil, @period=nil>}>
      def register_removed(entity)
        @changed_entities.delete entity
        @clean_entities.delete   entity

        return if @new_entities.delete? entity

        register_on @removed_entities, entity
      end

      private

      def register_on(list, entity, ignore: []) # :nodoc:
        return if entity.id.to_s.empty?
        return if already_present_on_lists?(entity, ignore)

        list.add entity
      end

      def already_present_on_lists?(entity, lists_to_ignore) # :nodoc:
        (
          [
            @new_entities, @changed_entities, @removed_entities
          ] - lists_to_ignore
        ).any? { |list| list.include? entity }
      end
    end
  end
end
