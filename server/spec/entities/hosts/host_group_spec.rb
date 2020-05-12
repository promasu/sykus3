require 'spec_helper'

module Sykus

  describe Hosts::HostGroup do
    it { should have_property :id }
    it { should have_property :name }

    it { should have_many :hosts }

    it { should validate_presence_of :name }

    it { should validate_uniqueness_of :name }
  end

end

