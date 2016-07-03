require 'spec_helper'

module SalarySummary
  describe Client do
    let(:mongodb_client) { double(:client) }
    let(:database)       { double(:database) }

    it 'creates a MongoDB database and returns the client to be used' do
      allow(::Mongo::Client).to receive(:new).with(
                                'mongodb://127.0.0.1:27017/salary_summary'
                                ).and_return mongodb_client

      expect(mongodb_client).to receive(:database).and_return database

      expect(described_class.database).to eql database
    end
  end
end
