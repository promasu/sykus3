module Sykus; module Includes

  # Establishes database connection, loads all Entities and
  # auto-updates DB schema.
  module EntityLoader
    private
    def self.init

      case APP_ENV
      when :dev, :prod
        login = YAML.load_file '/var/lib/sykus3/db.yaml'
        uri = "mysql://#{login[:user]}:#{login[:pass]}@localhost/#{login[:db]}"
          uri << '?socket=/run/mysqld/mysqld.sock'
      when :test
        uri = 'sqlite::memory:'
      else
        raise
      end

      DataMapper.setup :default, uri
      DataMapper::Model.raise_on_save_failure = true
      DataMapper.repository(:default).adapter.resource_naming_convention = 
        DataMapper::NamingConventions::Resource::
        UnderscoredAndPluralizedWithoutModule
    end

    def self.load_entities
      files = File.dirname(__FILE__) + '/../entities/**/*.rb'
      Dir[files].each { |entity| require entity }
      DataMapper.finalize
    end

    init
    load_entities
  end

end; end

