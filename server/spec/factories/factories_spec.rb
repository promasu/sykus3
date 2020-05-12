require 'spec_helper'

module Sykus

  class ::Factory
    def self.factories
      @@attrs.keys
    end
  end

  Factory.factories.each do |factory|
    describe factory do
      subject { Factory.build factory }

      it { should be_valid }

      it 'saves' do
        subject.save
      end
    end
  end

end

