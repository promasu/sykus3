require 'spec_helper'

module Sykus

  describe Calendar::Resource do
    it { should have_property :name }
    it { should have_property :active }

    it { should have_many :events }

    it { should validate_presence_of :name }
    it { should validate_presence_of :active }
  end

end

