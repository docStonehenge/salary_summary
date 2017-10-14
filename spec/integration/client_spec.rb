require 'spec_helper'

describe 'Databases::MongoDB::Client integration tests', integration: true do
  subject { SalarySummary::Databases::MongoDB::Client.new }

  it 'sets the default database logging to a log file' do
    SalarySummary::Databases::MongoDB::Client.set_database_logging
    expect(Mongo::Logger.logger).to be_debug
  end

  describe 'starting real connection' do
    before do
      Mongo::Logger.logger.level = Logger::INFO
    end

    it 'connects correctly to database using properties file' do
      expect(subject.connection.database.name).to eql 'salary_summary'
    end
  end

  describe 'fetching collection correctly' do
    before do
      Mongo::Logger.logger.level = Logger::INFO
    end

    it 'returns collection based on name, fetched as key from db connection' do
      collection = subject.database_collection(:salaries)

      expect(collection).to be_an_instance_of(Mongo::Collection)
      expect(collection.name).to eql 'salaries'
    end
  end

  after do
    subject.connection.close
  end
end
