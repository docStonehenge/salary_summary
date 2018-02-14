require 'database_cleaner'

RSpec.configure do |config|
  database_setup = lambda do
    client = Mongo::Client.new(
      SalarySummary::Databases::URIParser.parse_based_on_file
    )

    DatabaseCleaner[:mongo].db = client.database

    client.close
  end

  config.before(:suite) do
    DatabaseCleaner[:mongo].strategy = :truncation
  end

  config.before(:each, :db_integration) do
    @stdout_clone = $stdout
    $stdout = File.open(File::NULL, 'w')

    database_setup.call

    DatabaseCleaner[:mongo].start
  end

  config.after(:each, :db_integration) do
    database_setup.call
    DatabaseCleaner[:mongo].clean
    $stdout = @stdout_clone
  end
end
