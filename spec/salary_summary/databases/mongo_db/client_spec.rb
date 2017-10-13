require 'spec_helper'

module SalarySummary
  module Databases
    module MongoDB
      describe Client do
        let(:mongodb_client) { double(:client) }
        let(:logger)         { double(:logger) }

        describe '.set_database_logging' do
          before do
            allow(Mongo::Logger).to receive(:logger).and_return logger
          end

          it 'sets the default database logging to a log file', integration: true do
            expect(Mongo::Logger).to receive(:logger=).with(an_instance_of(::Logger))
            expect(logger).to receive(:level=).with(::Logger::DEBUG)

            described_class.set_database_logging
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
          it 'loads DB properties from file and sets DB connection' do
            expect(::Mongo::Client).to receive(:new).with(
                                         'mongodb://127.0.0.1:27017/salary_summary'
                                       ).and_return mongodb_client

            subject = described_class.instance

            expect(subject.instance_variable_get(:@db_connection)).to eql mongodb_client
          end

          it 'raises ConnectionPropertiesError on loading problems' do
            expect(YAML).to receive(
                              :load_file
                            ).once.with(ENV['DB_PROPERTIES_FILE']).and_raise(TypeError)

            expect {
              described_class.instance_eval { new }
            }.to raise_error(
                   Databases::ConnectionPropertiesError,
                   'Error while loading db/properties.yml file. Make sure that all key-value pairs are correctly set or file exists.'
                 )
          end
        end
      end
    end
  end
end
