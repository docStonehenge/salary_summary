# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'salary_summary/version'

Gem::Specification.new do |spec|
  spec.name          = "salary_summary"
  spec.version       = SalarySummary::VERSION
  spec.authors       = ["Victor Alexandre"]
  spec.email         = ["victor.alexandrefs@gmail.com"]

  spec.summary       = %q{Calculates your salary entries at command line.}
  spec.description   = %q{Every time we need a simple table solution for calculations, we tend to use Excel. No need for that with this CLI solution.}
  spec.homepage      = ""
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "database_cleaner", '~> 1.6', '>= 1.6.2'
  spec.add_development_dependency "simplecov", "~> 0.15"

  spec.add_runtime_dependency 'table_print', '~> 1.5'
  spec.add_runtime_dependency 'mongo', '~> 2.2', '>= 2.2.5'
  spec.add_runtime_dependency 'dotenv', '~> 2.2', '>= 2.2.1'
end
