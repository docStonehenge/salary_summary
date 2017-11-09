require 'mongo'

module SalarySummary
  module Databases
    module MongoDB
      class Client
        attr_reader :db_client, :id_generator

        # Sets a new instance of Client as <tt>connection</tt> on running thread.
        def self.new_connection
          self.connection = new
        end

        # Sets an instance of Client as <tt>connection</tt> on running thread.
        def self.connection=(client)
          Thread.current.thread_variable_set(:connection, client)
        end

        # Returns <tt>connection</tt> Client on running thread.
        def self.connection
          Thread.current.thread_variable_get(:connection)
        end

        # Sets logger level and file for connections.
        def self.set_database_logging
          Mongo::Logger.logger       = ::Logger.new('log/mongodb.log')
          Mongo::Logger.logger.level = ::Logger::DEBUG
        end

        # Initializes instance with an <tt>id_generator</tt> object and a <tt>db_client</tt>
        # based on database file properties parsed.
        # Raises a Databases::ConnectionError if URI parsed is invalid.
        def initialize
          @id_generator = ::Mongo::Operation::ObjectIdGenerator.new

          @db_client    = ::Mongo::Client.new(
            Databases::URIParser.parse_based_on_file
          )
        rescue ::Mongo::Error::InvalidURI => e
          raise Databases::ConnectionError, e
        end

        # Returns collection corresponding to the given <tt>name</tt>.
        def database_collection(name)
          db_client[name.to_sym]
        end
      end
    end
  end
end
