require 'spec_helper'

require 'services/users/delete_user_class'

module Sykus

  describe Users::DeleteUserClass do
    let (:identity) { IdentityTestGod.new } 
    let (:delete_user_class) { Users::DeleteUserClass.new identity }

    let! (:uc) { Factory Users::UserClass }

    it 'deletes a class' do
      delete_user_class.run uc.id

      Users::UserClass.get(uc.id).should be_nil
      check_entity_evt(EntitySet.new(Users::UserClass), uc.id, true)
    end

    context 'with class calendar events' do
      let! (:event) { Factory Calendar::Event, type: :class, user_class: uc }

      it 'works' do
        delete_user_class.run uc.id
        Users::UserClass.get(uc.id).should be_nil
      end
    end

    context 'errors' do
      it 'raises on permission violation' do
        check_service_permission(:user_classes_write, 
                                 Users::DeleteUserClass, :run, uc.id)
      end

      context 'with class members' do
        before :each do 
          Factory Users::User, user_class: uc
        end

        it 'raises' do
          expect {
            delete_user_class.run uc.id
          }.to raise_error Exceptions::Input
        end
      end

      it 'raises on invalid id' do
        expect {
          delete_user_class.run 4200
        }.to raise_error Exceptions::NotFound
      end
    end
  end

end

