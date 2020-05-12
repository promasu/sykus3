module Sykus; module Includes

  # Loads all Helpers.
  module HelpersLoader
    private
    def self.run
      files = File.dirname(__FILE__) + '/../helpers/**/*.rb'
      Dir[files].each { |helper| require helper }
    end

    run
  end

end; end

