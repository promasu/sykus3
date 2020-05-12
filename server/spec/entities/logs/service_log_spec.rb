require 'spec_helper'

module Sykus

  describe Logs::ServiceLog do
    it { should have_property :created_at }
    it { should have_property :username }
    it { should have_property :service }
    it { should have_property :input }
    it { should have_property :output }

    it { should validate_presence_of :username }
    it { should validate_presence_of :service }
  end

end

