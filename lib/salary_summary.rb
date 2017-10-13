require "salary_summary/version"

require 'singleton'
require 'date'
require 'csv'
require 'fileutils'
require 'table_print'

require 'salary_summary/databases/mongo_db/client'
require 'salary_summary/registry'

require 'salary_summary/entities/comparison_error'
require 'salary_summary/entities/salary'

require 'salary_summary/interpreters/information_interpreter'

require 'salary_summary/builders/table_builder'

require 'salary_summary/exporters/annual_salary_report'

require 'salary_summary/queries/entity_not_found_error'
require 'salary_summary/repositories/salaries_repository'

module SalarySummary
  def self.included(_klass)
    Databases::MongoDB::Client.set_database_logging
  end
end
