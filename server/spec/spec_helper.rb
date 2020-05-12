$:.unshift(File.dirname(__FILE__) + '/../lib')

module Sykus

  TEST_ENV = true
  SIMPLECOV = true

  require 'common'
  require_relative './spec_helper_methods'
  require_relative './spec_helper_patches'

  RSpec.configure do |config|
    config.include DataMapper::Matchers
    config.include Rack::Test::Methods
    config.include SpecHelpers

    config.before :suite do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with :truncation
    end

    config.before :each do
      REDIS.flushdb
      DatabaseCleaner.start
    end

    config.after :each do
      DatabaseCleaner.clean
    end

    if ENV['PROF']
      config.before :suite do
        RubyProf.start
      end

      config.after :suite do
        res = RubyProf.stop
        f = File.open('profile.out', 'w+')
        RubyProf::FlatPrinter.new(res).print(f, {})
        f.close
      end
    end
  end

  factories = File.dirname(__FILE__) + '/../spec/factories/**/*_factory.rb'
  Dir[factories].each { |factory| require factory }

  DataMapper.auto_migrate!
end

