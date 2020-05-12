require 'spec_helper'

module Sykus

  describe Webfilter::Entry do
    it { should have_property :id }
    it { should have_property :domain }
    it { should have_property :comment }
    it { should have_property :type }

    it { should validate_presence_of :domain }
    it { should validate_presence_of :type }

    it { should validate_uniqueness_of :domain }
  end

end

