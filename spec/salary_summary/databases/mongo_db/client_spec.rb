require 'spec_helper'

module SalarySummary
  module Databases
    module MongoDB
      describe Client do
        let(:mongodb_client) { double(:client) }
        let(:logger)         { double(:logger) }

        describe '.new_connection' do
          it 'sets a new client instance as connection on current Thread' do
            allow(described_class).to receive(:new).and_return mongodb_client

            described_class.new_connection

            expect(Thread.current.thread_variable_get(:connection)).to equal mongodb_client
          end
        end

        describe '.connection= client' do
          it 'registers client object on current Thread as connection variable' do
            described_class.connection = mongodb_client
            expect(Thread.current.thread_variable_get(:connection)).to equal mongodb_client
          end
        end

        describe '.connection' do
          it 'returns connection variable set on current Thread' do
            described_class.connection = mongodb_client

            expect(described_class.connection).to equal mongodb_client
          end
        end

        describe '.set_database_logging' do
          before do
            allow(Mongo::Logger).to receive(:logger).and_return logger
          end

          it 'sets the default database logging to a log file' do
            log_file = double

            allow(::Logger).to receive(:new).once.with('log/mongodb.log').and_return log_file
            expect(Mongo::Logger).to receive(:logger=).with(log_file)
            expect(logger).to receive(:level=).with(::Logger::DEBUG)

            described_class.set_database_logging
          end
        end

        describe '#initialize' do
          let(:id_gen) { double(:id_gen) }

          before do
            expect(
              Databases::URIParser
            ).to receive(:parse_based_on_file).once.and_return 'uri'
          end

          it 'sets DB connection and ID generator' do
            expect(::Mongo::Client).to receive(:new).with(
                                         'uri'
                                       ).and_return mongodb_client

            expect(
              ::Mongo::Operation::ObjectIdGenerator
            ).to receive(:new).once.and_return id_gen

            subject = described_class.new

            expect(subject.db_client).to eql mongodb_client
            expect(subject.id_generator).to eql id_gen
          end

          it 'raises ConnectionError if MongoDB client receives an invalid URI' do
            exception = Mongo::Error::InvalidURI.new('foo', 'details')

            expect(::Mongo::Client).to receive(:new).with('uri').and_raise exception

            expect {
              described_class.new
            }.to raise_error(
                   Databases::ConnectionError,
                   "Error while connecting to database. Details: #{exception.message}"
                 )
          end
        end

        describe '#database_collection name' do
          let(:collection) { double(:collection) }

          before do
            expect(::Mongo::Client).to receive(:new).with(
                                         'mongodb://127.0.0.1:27017/salary_summary'
                                       ).and_return mongodb_client
          end

          it 'returns collection based on name, fetched as key from db connection' do
            subject = described_class.new

            expect(subject.db_client).to receive(:[]).once.with(:foo).and_return collection

            expect(
              subject.database_collection(:foo)
            ).to eql collection
          end
        end
      end
    end
  end
end
