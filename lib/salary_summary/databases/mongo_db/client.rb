require 'mongo'

module SalarySummary
  module Databases
    module MongoDB
      class Client
        def self.instance
          @db ||= ::Mongo::Client.new(
            'mongodb://127.0.0.1:27017/salary_summary'
          )
        end

        def self.set_database_logging
          Mongo::Logger.logger = ::Logger.new('log/mongodb.log')
          Mongo::Logger.logger.level = ::Logger::DEBUG
        end
      end
    end
  end
end
