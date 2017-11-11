require "salary_summary/version"

require 'singleton'
require 'date'
require 'csv'
require 'fileutils'
require 'table_print'

require 'salary_summary/databases/uri_parser'
require 'salary_summary/databases/connection_error'
require 'salary_summary/databases/connection_properties_error'
require 'salary_summary/databases/mongo_db/client'

require 'salary_summary/persistence/entity_registry'
require 'salary_summary/persistence/unit_of_work_not_started_error'
require 'salary_summary/persistence/unit_of_work'

require 'salary_summary/registry'
require 'salary_summary/repositories/repository_registry'
require 'salary_summary/repositories/salaries_repository'

require 'salary_summary/entities/comparison_error'
require 'salary_summary/entities/salary'

require 'salary_summary/interpreters/information_interpreter'

require 'salary_summary/builders/table_builder'

require 'salary_summary/exporters/annual_salary_report'

require 'salary_summary/queries/entity_not_found_error'

module SalarySummary
  require 'dotenv'
  Dotenv.load

  def self.included(_klass)
    Databases::MongoDB::Client.set_database_logging
  end
end
