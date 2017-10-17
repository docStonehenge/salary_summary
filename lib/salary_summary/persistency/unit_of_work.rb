module SalarySummary
  module Persistency
    class UnitOfWork
      # Initializes an instance with four new Set objects: <tt>clean_entities</tt>,
      # <tt>new_entities</tt>, <tt>changed_entities</tt> and <tt>removed_instances</tt>
      def initialize
        @clean_entities   = Set.new
        @new_entities     = Set.new
        @changed_entities = Set.new
        @removed_entities = Set.new
      end

      # Registers <tt>entity</tt> on clean entities list, avoiding duplicates.
      # Ingores entities without IDs and if present on other lists.
      # Returns the +set+ with entity added or +nil+ if entity has no ID or it's a duplicate.
      #
      # Examples
      #
      #   register_clean(SalarySummary::Entities::Salary.new(id: 123))
      #   # => #<Set: {#<SalarySummary::Entities::Salary:0x007f8b1a9028b8 @id=123, @amount=nil, @period=nil>}>
      def register_clean(entity)
        register_on(@clean_entities, entity)
      end

      # Registers <tt>entity</tt> on new entities list, avoiding duplicates.
      # Ingores entities without IDs and if present on other lists.
      # Returns the +set+ with entity added or +nil+ if entity has no ID or it's a duplicate.
      #
      # Examples
      #
      #   register_new(SalarySummary::Entities::Salary.new(id: 123))
      #   # => #<Set: {#<SalarySummary::Entities::Salary:0x007f8b1a9028b8 @id=123, @amount=nil, @period=nil>}>
      def register_new(entity)
        register_on(@new_entities, entity)
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
        register_on(@changed_entities, entity, ignore_list: @clean_entities)
      end

      # Registers <tt>entity</tt> on removed entities list, avoiding duplicates.
      # Ingores entities without IDs and if present on other lists.
      # Returns the +set+ with entity added or +nil+ if entity has no ID or it's a duplicate.
      #
      # Examples
      #
      #   register_removed(SalarySummary::Entities::Salary.new(id: 123))
      #   # => #<Set: {#<SalarySummary::Entities::Salary:0x007f8b1a9028b8 @id=123, @amount=nil, @period=nil>}>
      def register_removed(entity)
        register_on(@removed_entities, entity, ignore_list: @clean_entities)
      end

      private

      def register_on(list, entity, ignore_list: nil) # :nodoc:
        return if entity.id.to_s.empty?
        return if already_present_on_lists?(entity, ignored_list: ignore_list)

        list << entity
      end

      def already_present_on_lists?(entity, ignored_list: nil) # :nodoc:
        lists = [
          @clean_entities, @new_entities, @changed_entities, @removed_entities
        ]

        lists.delete(ignored_list)
        lists.any? { |list| list.include? entity }
      end
    end
  end
end
