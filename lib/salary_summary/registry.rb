module SalarySummary
  class Registry
    include Singleton

    attr_reader :salaries

    def self.salaries_list
      salaries.values
    end

    def self.salaries
      instance.salaries
    end

    def self.set(object)
      instance.set(object)
    end

    def self.get(id)
      instance.get(id)
    end

    def initialize
      @salaries = {}
    end

    def set(instance)
      salaries[instance.id] = instance
    end

    def get(id)
      salaries.dig(id)
    end
  end
end
