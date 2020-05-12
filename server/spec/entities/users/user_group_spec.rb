require 'spec_helper'

module Sykus

  describe Users::UserGroup do
    it { should have_property :id }
    it { should have_property :name }

    it { should belong_to :owner }
    it { should have_many :users }

    it { should validate_presence_of :name }

    context 'system id' do
      subject { Factory Users::UserGroup }
      it 'has correct id' do
        subject.system_id.should == subject.id + 10000
      end
    end

  end

end

