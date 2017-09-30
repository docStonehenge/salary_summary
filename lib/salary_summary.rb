require "salary_summary/version"

require 'singleton'
require 'date'
require 'csv'
require 'fileutils'
require 'mongo'
require 'table_print'

require 'salary_summary/client'
require 'salary_summary/registry'

require 'salary_summary/resources/comparison_error'
require 'salary_summary/resources/salary'

require 'salary_summary/interpreters/information_interpreter'
require 'salary_summary/interpreters/salary_report_interpreter'

require 'salary_summary/builders/table_builder'

require 'salary_summary/exporters/annual_salary_report'

require 'salary_summary/queries/entity_not_found_error'
require 'salary_summary/repositories/salaries_repository'

module SalarySummary
  def self.included(_klass)
    Client.set_database_logging
  end
end
