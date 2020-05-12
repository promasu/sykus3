require 'spec_helper'

module Sykus

  describe Users::Session do
    it { should have_property :id }

    it { should have_property :ip }
    it { should have_property :updated_at }

    it { should belong_to :user }
    it { should belong_to :host }
  end

end

