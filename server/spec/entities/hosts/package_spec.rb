require 'spec_helper'

module Sykus

  describe Hosts::Package do
    it { should have_property :id }
    it { should have_property :id_name }
    it { should have_property :name }
    it { should have_property :category }
    it { should have_property :text }
    it { should have_property :default }
    it { should have_property :selected }
    it { should have_property :installed }

    it { should validate_presence_of :id_name }
    it { should validate_presence_of :name }
    it { should validate_presence_of :category }
    it { should validate_presence_of :text }

    it { should validate_uniqueness_of :id_name }
    it { should validate_uniqueness_of :name }
  end

end

