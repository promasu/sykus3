require 'spec_helper'

module Sykus

  describe PermissionTable do
    let (:permission_list) { Config::Permissions::PermissionList }
    subject { PermissionTable.new }

    it 'has a constant list of permission symbols' do
      permission_list.should be_a Set
      permission_list.each { |p| p.should be_a Symbol  }
    end

    context '#new' do
      it 'has all flags disabled' do
        permission_list.each do |p|
          subject.get(p).should == false
        end

        subject.permissions.should == []
      end

      it 'can set all flags' do
        permission_list.each do |p|
          subject.set(p, true)
          subject.get(p).should == true
          subject.set(p, false)
          subject.get(p).should == false
        end
      end
    end

    context '#new and #enable_all' do
      it 'has all flags enabled' do
        subject.enable_all

        permission_list.each do |p|
          subject.get(p).should == true
        end

        subject.permissions.should =~ permission_list.to_a
      end
    end
  end

end

