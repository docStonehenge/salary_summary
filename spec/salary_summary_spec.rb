require 'spec_helper'
require 'dotenv'

describe SalarySummary do
  it 'has a version number' do
    expect(SalarySummary::VERSION).not_to be nil
  end

  it 'calls MongoDB client logging mechanism and loads dotenv file' do
    subject = Class.new

    expect(
      SalarySummary::Databases::MongoDB::Client
    ).to receive(:set_database_logging).once

    expect(Dotenv).to receive(:load).once

    subject.include(SalarySummary)
  end
end
