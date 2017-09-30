module SalarySummary
  class Client
    def self.instance
      @db ||= ::Mongo::Client.new(
        'mongodb://127.0.0.1:27017/salary_summary'
      )
    end

    def self.set_database_logging
      Mongo::Logger.logger = ::Logger.new('log/mongodb.log')
      Mongo::Logger.logger.level = ::Logger::INFO
    end
  end
end
