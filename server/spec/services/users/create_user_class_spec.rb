require 'spec_helper'

require 'services/users/create_user_class'

module Sykus

  describe Users::CreateUserClass do
    let (:identity) { IdentityTestGod.new } 
    let (:create_user_class) { Users::CreateUserClass.new identity }

    it 'creates a user class' do
      res = create_user_class.run name: '7c' 

      res[:id].should be_a Integer

      ref = Users::UserClass.get(res[:id])
      ref.name.should == '7c'
      ref.grade.should == 7
      check_entity_evt(EntitySet.new(Users::UserClass), res[:id], false)
    end

    it 'creates a user class without a grade' do
      res = create_user_class.run name: 'AB' 

      res[:id].should be_a Integer

      ref = Users::UserClass.get(res[:id])
      ref.name.should == 'AB'
      ref.grade.should be_nil
    end


    it 'fails on duplicate class' do
      create_user_class.run name: '7c' 

      expect {
        create_user_class.run name: '7c'
      }.to raise_error Exceptions::Input
    end

    context 'errors' do
      it '#run raises on permission violation' do
        check_service_permission(:user_classes_write, Users::CreateUserClass, 
                                 :run, { name: '7c' })
      end
    end
  end

end

