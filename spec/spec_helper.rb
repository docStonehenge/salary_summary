$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'salary_summary'

ENV['ENVIRONMENT'] = 'test'
ENV['DB_PROPERTIES_FILE'] = 'db/_test_properties.yml'
