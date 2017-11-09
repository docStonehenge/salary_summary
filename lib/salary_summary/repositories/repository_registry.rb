module SalarySummary
  module Repositories
    class RepositoryRegistry
      # Returns the repository object found by <tt>class_name</tt>, where <tt>class_name</tt>
      # can be the entity object class or the repository object class.
      # If not found by the first time called, sets a new object of repository type for <tt>class_name</tt>
      # on map and returns it.
      # Raises NameError if <tt>class_name</tt> is not a valid constant or a class
      # that doesn't exist.
      # It's a Thread-safe method, so it, at first, tries to get current Thread's registry
      # object and calls it; if no registry is found, it registers a new one on the Thread
      # to use it.
      def self.[](class_name)
        (repositories || new_repositories)[class_name]
      end

      # Registers a new Registry object into current Thread as <tt>repositories</tt>.
      def self.new_repositories
        Thread.current.thread_variable_set(:repositories, new)
      end

      # Returns the Registry object registered into current Thread as <tt>repositories</tt>.
      def self.repositories
        Thread.current.thread_variable_get(:repositories)
      end

      # Initializes registry object with an empty <tt>repositories</tt> Hash.
      def initialize
        @repositories = {}
      end

      # Returns the repository object found by <tt>class_name</tt>, where <tt>class_name</tt>
      # can be the entity object class or the repository object class.
      # If not found by the first time called, sets a new object of repository type for <tt>class_name</tt>
      # on map and returns it.
      # Raises NameError if <tt>class_name</tt> is not a valid constant or a class
      # that doesn't exist.
      def [](class_name)
        repository_name = valid_repository_name_for class_name

        @repositories[repository_name].tap do |repository|
          unless repository
            return @repositories[repository_name] = repository_name.new
          end
        end
      end

      private

      def valid_repository_name_for(type) # :nodoc:
        repository_type = type.to_s.gsub(/^.*::/, '').gsub(/Repository/, '')
        Module.const_get("SalarySummary::Repositories::#{repository_type}Repository")
      rescue NameError
        Module.const_get("#{repository_type}Repository")
      end
    end
  end
end
