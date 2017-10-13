require 'mongo'

module SalarySummary
  module Databases
    module MongoDB
      class Client
        include Singleton

        attr_reader :connection

        def self.set_database_logging
          Mongo::Logger.logger = ::Logger.new('log/mongodb.log')
          Mongo::Logger.logger.level = ::Logger::DEBUG
        end

        def initialize
          @connection = ::Mongo::Client.new(parse_database_url)
        end

        def database_collection(name)
          connection[name.to_sym]
        end

        private

        def parse_database_url
          properties = load_database_properties

          protocol, host, port, database = properties.values_at(
                                  'protocol', 'host', 'port', 'database'
                                )

          "#{protocol}://#{host}:#{port}/#{database}"
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
