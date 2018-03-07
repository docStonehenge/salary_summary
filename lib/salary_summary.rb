require "salary_summary/version"

require 'singleton'
require 'bigdecimal'
require 'date'
require 'csv'
require 'fileutils'
require 'table_print'
require 'persisty'

require 'salary_summary/repositories/salaries_repository'

require 'salary_summary/entities/roles/salary_document'
require 'salary_summary/entities/salary'

require 'salary_summary/interpreters/information_interpreter'

require 'salary_summary/builders/table_builder'

require 'salary_summary/exporters/annual_salary_report'

module SalarySummary
  require 'dotenv'
  Dotenv.load

  def self.included(_klass)
    Persisty::Databases::MongoDB::Client.set_database_logging
  end
end
