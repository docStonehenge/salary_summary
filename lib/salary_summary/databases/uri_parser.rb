require 'erb'

module SalarySummary
  module Databases
    class URIParser
      class << self
        def perform
          protocol, host, port, database = load_database_properties.values_at(
                                  'protocol', 'host', 'port', 'database'
                                )

          "#{protocol}://#{host}:#{port}/#{database}"
        end

        private

        def load_database_properties
          YAML.safe_load(
            ERB.new(File.read(File.join(Dir.pwd, 'db/properties.yml'))).result,
            [], [], true
          ).dig('environments', ENV['ENVIRONMENT'])
        rescue
          raise Databases::ConnectionPropertiesError
        end
      end
    end
  end
end
