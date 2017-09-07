module SalarySummary
  class Registry
    include Singleton

    attr_reader :salaries

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
