require 'spec_helper'

module Sykus

  describe Logs::SessionLog do
    it { should have_property :created_at }
    it { should have_property :username }
    it { should have_property :ip }
    it { should have_property :type }

    it { should validate_presence_of :username }
    it { should validate_presence_of :type }
  end

end

