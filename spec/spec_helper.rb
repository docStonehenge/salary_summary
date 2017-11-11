$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'salary_summary'

require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
end

ENV['ENVIRONMENT'] = 'test'

Dir["spec/support/**/*.rb"].each { |f| load f }
