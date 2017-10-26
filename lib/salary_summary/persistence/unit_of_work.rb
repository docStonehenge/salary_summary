module SalarySummary
  module Persistence
    class UnitOfWork
      # Sets a new instance of UnitOfWork as <tt>current_uow</tt> on running thread.
      def self.new_current
        self.current = new(EntityRegistry.new)
      end

      # Sets an instance of UnitOfWork as <tt>current_uow</tt> on running thread.
      def self.current=(unit_of_work)
        Thread.current.thread_variable_set(:current_uow, unit_of_work)
      end

      # Returns <tt>current_uow</tt> UnitOfWork on running thread.
      def self.current
        Thread.current.thread_variable_get(:current_uow)
      end

      # Initializes an instance with three new Set objects and an EntityRegistry
      def initialize(entity_registry)
        @clean_entities   = entity_registry
        @new_entities     = Set.new
        @changed_entities = Set.new
        @removed_entities = Set.new
      end

      # Registers <tt>entity</tt> on clean entities map, avoiding duplicates.
      # Ingores entities without IDs and if present on other lists.
      # Returns the +entity+ added or +nil+ if entity has no ID or it's a duplicate.
      #
      # Examples
      #
      #   register_clean(SalarySummary::Entities::Salary.new(id: 123))
      #   # => <SalarySummary::Entities::Salary:0x007f8b1a9028b8 @id=123, @amount=nil, @period=nil>
      def register_clean(entity)
        register_on @clean_entities, entity, ignore: [@new_entities]
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
        register_on @new_entities, entity, ignore: [@clean_entities]
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
        register_on @changed_entities, entity, ignore: [@clean_entities]
      end

      # Tries to remove <tt>entity</tt> from changed entities list, registers it
      # on removed entities list and removes from clean entities map, avoiding duplicates.
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
            @clean_entities, @new_entities, @changed_entities, @removed_entities
          ] - lists_to_ignore
        ).any? { |list| list.include? entity }
      end
    end
  end
end
