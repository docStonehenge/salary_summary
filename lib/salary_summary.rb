require "salary_summary/version"

require 'singleton'
require 'bigdecimal'
require 'date'
require 'csv'
require 'fileutils'
require 'table_print'
require 'salary_summary/extensions/float'
require 'salary_summary/extensions/array'
require 'salary_summary/extensions/hash'
require 'salary_summary/extensions/string'
require 'salary_summary/extensions/integer'
require 'salary_summary/extensions/boolean'
require 'salary_summary/extensions/false_class'
require 'salary_summary/extensions/true_class'
require 'salary_summary/extensions/nil_class'
require 'salary_summary/extensions/date'
require 'salary_summary/extensions/time'
require 'salary_summary/extensions/big_decimal'
require 'salary_summary/extensions/bson_object_id'

require 'salary_summary/databases/uri_parser'
require 'salary_summary/databases/connection_error'
require 'salary_summary/databases/connection_properties_error'
require 'salary_summary/databases/mongo_db/client'

require 'salary_summary/persistence/entities/registry'
require 'salary_summary/persistence/unit_of_work_not_started_error'
require 'salary_summary/persistence/unit_of_work'
require 'salary_summary/persistence/document_definitions/base'
require 'salary_summary/persistence/document_definitions/salary'
require 'salary_summary/persistence/entities/field'

require 'salary_summary/repositories/registry'
require 'salary_summary/repositories/base'
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
