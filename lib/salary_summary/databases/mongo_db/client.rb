require 'mongo'

module SalarySummary
  module Databases
    module MongoDB
      class Client
        attr_reader :connection, :id_generator

        def self.set_database_logging
          Mongo::Logger.logger       = ::Logger.new('log/mongodb.log')
          Mongo::Logger.logger.level = ::Logger::DEBUG
        end

        def initialize
          @id_generator = ::Mongo::Operation::ObjectIdGenerator.new

          @connection   = ::Mongo::Client.new(
            Databases::URIParser.parse_based_on_file
          )
        rescue ::Mongo::Error::InvalidURI => e
          raise Databases::ConnectionError, e
        end

        def database_collection(name)
          connection[name.to_sym]
        end
      end
    end
  end
end
