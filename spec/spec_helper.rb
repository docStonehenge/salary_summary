require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'salary_summary'

ENV['ENVIRONMENT'] = 'test'

Dir["spec/support/**/*.rb"].each { |f| load f }

RSpec.configure do |config|
  config.before(:each, type: :database_integration) do
    client = ::Mongo::Client.new(
      SalarySummary::Databases::URIParser.parse_based_on_file
    )

    client.database.collections.each(&:drop)
    client.close
  end
end
