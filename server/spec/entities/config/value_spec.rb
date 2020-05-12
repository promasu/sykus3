require 'spec_helper'

module Sykus

  describe Config::Value do
    it { should have_property :id }
    it { should have_property :name }
    it { should have_property :json_value }

    it { should validate_presence_of :name }
    it { should validate_presence_of :json_value }

    it { should validate_uniqueness_of :name }
  end

end

