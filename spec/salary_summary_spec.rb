require 'spec_helper'

describe SalarySummary do
  it 'has a version number' do
    expect(SalarySummary::VERSION).not_to be nil
  end

  it 'sets MongoDB client logging mechanism' do
    subject = Class.new

    expect(
      Persisty::Databases::MongoDB::Client
    ).to receive(:set_database_logging).once

    subject.include(SalarySummary)
  end
end
