require 'spec_helper'

module Sykus

  describe Users::UserClass do
    it { should have_property :name }
    it { should have_property :grade }

    it { should have_many :users }

    it { should validate_presence_of :name }
  end

end

