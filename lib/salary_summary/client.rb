module SalarySummary
  class Client
    def self.instance
      @db ||= ::Mongo::Client.new(
        'mongodb://127.0.0.1:27017/salary_summary'
      )
    end

    def self.database
      instance.database
    end
  end
end
