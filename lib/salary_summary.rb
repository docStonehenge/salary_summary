require "salary_summary/version"

require 'csv'
require 'fileutils'
require 'mongo'

require 'salary_summary/client'

require 'salary_summary/resources/salary'

require 'salary_summary/calculators/annual_salary_calculator'

require 'salary_summary/interpreters/information_interpreter'
require 'salary_summary/interpreters/salary_report_interpreter'

require 'salary_summary/builders/table_builder'

require 'salary_summary/exporters/annual_salary_report'

module SalarySummary
  # Your code goes here...
end
