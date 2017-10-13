require 'mongo'

module SalarySummary
  module Databases
    module MongoDB
      class Client
        include Singleton

        def self.set_database_logging
          Mongo::Logger.logger = ::Logger.new('log/mongodb.log')
          Mongo::Logger.logger.level = ::Logger::DEBUG
        end

        def initialize
          @db_connection = ::Mongo::Client.new(parse_database_url)
        end

        private

        def parse_database_url
          properties = load_database_properties

          protocol = properties.dig('protocol')
          host     = "#{properties.dig('host')}:#{properties.dig('port')}"
          database = properties.dig('database')

          "#{protocol}://#{host}/#{database}"
        end

        def load_database_properties
          YAML.load_file(
            ENV['DB_PROPERTIES_FILE']
          ).dig('environments', ENV['ENVIRONMENT'])
        rescue TypeError
          raise Databases::ConnectionPropertiesError
        end
      end
    end
  end
end
