require 'spec_helper'

module SalarySummary
  describe Client do
    let(:mongodb_client) { double(:client) }
    let(:logger)         { double(:logger) }

    describe '.client' do
      it 'sets MongoDB client to a database and returns the client to be used' do
        allow(::Mongo::Client).to receive(:new).with(
                                    'mongodb://127.0.0.1:27017/salary_summary'
                                  ).and_return mongodb_client

        expect(described_class.instance).to eql mongodb_client
      end
    end

    describe '.set_database_logging' do
      before do
        allow(Mongo::Logger).to receive(:logger).and_return logger
      end

      it 'sets the default database logging to a log file', integration: true do
        expect(Mongo::Logger).to receive(:logger=).with(an_instance_of(::Logger))
        expect(logger).to receive(:level=).with(::Logger::INFO)

        described_class.set_database_logging
      end

      it 'sets the default database logging to a log file' do
        log_file = double

        allow(::Logger).to receive(:new).once.with('log/mongodb.log').and_return log_file
        expect(Mongo::Logger).to receive(:logger=).with(log_file)
        expect(logger).to receive(:level=).with(::Logger::INFO)

        described_class.set_database_logging
      end
    end
  end
end
