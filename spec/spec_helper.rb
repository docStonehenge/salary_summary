$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'salary_summary'

ENV['ENVIRONMENT'] = 'test'

Dir["spec/support/**/*.rb"].each { |f| load f }
