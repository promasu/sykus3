module Sykus; module Includes

  # Loads all Objects.
  module ObjectLoader
    private
    def self.run
      files = File.dirname(__FILE__) + '/../objects/**/*.rb'
      Dir[files].each { |object| require object }
    end

    run
  end

end; end

