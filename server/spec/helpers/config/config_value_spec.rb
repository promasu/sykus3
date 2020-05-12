require 'spec_helper'


module Sykus
  describe Config::ConfigValue do
    it 'creates a config value (string)' do 
      Config::ConfigValue.set('test', 'bla')

      Config::ConfigValue.get('test').should == 'bla'
    end

    it 'creates a config value (string stripped)' do 
      Config::ConfigValue.set('test', '  bla ')

      Config::ConfigValue.get('test').should == 'bla'
    end

    it 'creates a config value (integer)' do 
      Config::ConfigValue.set('test', 123)

      Config::ConfigValue.get('test').should == 123
    end

    it 'creates a config value (bool)' do 
      Config::ConfigValue.set('test', true)

      Config::ConfigValue.get('test').should == true
    end

    it 'creates a config value (array)' do 
      Config::ConfigValue.set('test', [ 1, 2, 3, 'a' ])

      Config::ConfigValue.get('test').should == [ 1, 2, 3, 'a' ]
    end

    it 'overwrites a config value' do 
      Config::ConfigValue.set('test', 'bla')
      Config::ConfigValue.set('test', 'bla2')

      Config::ConfigValue.get('test').should == 'bla2'
    end

    it 'gets a config value (not present)' do
      Config::ConfigValue.get('test').should be_nil
    end
  end
end

