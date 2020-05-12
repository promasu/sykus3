require 'spec_helper'

module Sykus

  describe Users::User do
    it { should have_property :id }
    it { should have_property :username }
    it { should have_property :password_expired }
    it { should have_property :password_nt }
    it { should have_property :password_sha256 }
    it { should have_property :password_initial }
    it { should have_property :position_group }
    it { should have_property :admin_group }
    it { should have_property :quota_used_mb }

    it { should have_many :user_groups }

    it { should validate_presence_of :username }
    it { should validate_presence_of :password_expired }
    it { should validate_presence_of :password_nt }
    it { should validate_presence_of :password_sha256 }
    it { should validate_presence_of :position_group }
    it { should validate_presence_of :admin_group }

    it { should validate_uniqueness_of :username }
    it { 
      should validate_format_of(:username).
      with(/^[a-z]{2,12}[0-9]{0,3}$/) 
    }

    context 'debugging' do
      subject { Factory.build Users::User }
      it 'has nice inspect method' do
        subject.inspect.should include subject.id.to_s
        subject.inspect.should  include subject.username
      end
    end

    context 'system id' do
      subject { Factory Users::User }
      it 'has correct id' do
        subject.system_id.should == subject.id + 10000
      end
    end

    context 'position group' do
      subject { Factory.build Users::User }
      [ :person, :student, :teacher ].each do |group|
        it "has #{group} position group state" do
          subject.position_group = group
          subject.user_class = Factory Users::UserClass if group == :student

          subject.should be_valid
        end
      end
    end

    context 'admin group' do
      subject { Factory.build Users::User }
      [ :none, :junior, :senior, :super ].each do |group|
        it "has #{group} admin group state" do
          subject.admin_group = group
          subject.should be_valid
        end
      end
    end

    context 'full user name' do
      subject { Factory.build Users::User }

      it 'has a FullUserName object' do
        subject.full_name.should be_a Users::FullUserName
      end

      it 'has writable full user name' do
        newname = Users::FullUserName.new('Jane', 'Dove')
        subject.full_name = newname
        subject.full_name.should == newname
      end
    end

    context 'birthdate' do
      it 'raises on invalid birthdate' do
        user = Factory.build Users::User
        user.birthdate = '01.42.1932'
        user.valid?.should be_false
      end
    end
  end

end

