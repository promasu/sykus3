require 'spec_helper'

module Sykus

  describe Users::GetUserMaxQuota do
    let (:user) { nil }
    let (:subject) { Users::GetUserMaxQuota.get user }

    before :each do
      REDIS.set('diskspace.quota.student', 123)
      REDIS.set('diskspace.quota.teacher', 234)
      REDIS.set('diskspace.quota.admin', 456)
    end

    context 'quotas for student' do
      let! (:user) { 
        Factory Users::User, position_group: :student, admin_group: :junior
      }
      it 'returns correct values' do
        subject.should == 123
      end
    end

    context 'quotas for teacher' do
      let! (:user) { 
        Factory Users::User, position_group: :teacher, admin_group: :none
      }
      it 'returns correct values' do
        subject.should == 234
      end
    end

    context 'quotas for admin' do
      let! (:user) { 
        Factory Users::User, position_group: :student, admin_group: :senior
      }
      it 'returns correct values' do
        subject.should == 456
      end
    end

    context 'errors' do
      it 'raises on invalid user' do
        expect {
          subject
        }.to raise_error Exceptions::Input
      end
    end
  end

end

