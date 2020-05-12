require 'spec_helper'

module Sykus

  describe Webfilter::Category do
    it { should have_property :id }
    it { should have_property :name }
    it { should have_property :text }
    it { should have_property :default }
    it { should have_property :selected }

    it { should validate_presence_of :name }
    it { should validate_presence_of :text }

    it { should validate_uniqueness_of :name }
  end

end

