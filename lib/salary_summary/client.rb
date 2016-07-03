module SalarySummary
  class Client
    def self.database
      @db ||= ::Mongo::Client.new(
        'mongodb://127.0.0.1:27017/salary_summary'
      ).database
    end
  end
end
