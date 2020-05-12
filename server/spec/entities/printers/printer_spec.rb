require 'spec_helper'

module Sykus

  describe Printers::Printer do
    it { should have_property :id }
    it { should have_property :name }
    it { should have_property :url }
    it { should have_property :driver }

    it { should have_many :host_groups }

    it { should validate_presence_of :name }
    it { should validate_presence_of :url }
    it { should validate_presence_of :driver }

    it { should validate_uniqueness_of :name }
    it { should validate_uniqueness_of :url }
  end

end

