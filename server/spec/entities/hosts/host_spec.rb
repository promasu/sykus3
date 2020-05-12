require 'spec_helper'

module Sykus

  describe Hosts::Host do
    it { should have_property :id }
    it { should have_property :name }
    it { should have_property :ip }
    it { should have_property :mac }
    it { should have_property :cpu_speed }
    it { should have_property :ram_mb }
    it { should have_property :online }
    it { should have_property :ready }

    it { should belong_to :host_group }

    it { should validate_presence_of :name }
    it { should validate_presence_of :ip }
    it { should validate_presence_of :mac }
    it { should validate_presence_of :cpu_speed }
    it { should validate_presence_of :ram_mb }
    it { should validate_presence_of :online }
    it { should validate_presence_of :ready }

    it { should validate_uniqueness_of :mac }
    it { should validate_uniqueness_of :ip }
  end

end

