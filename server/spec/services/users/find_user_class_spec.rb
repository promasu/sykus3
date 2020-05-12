require 'spec_helper'

require 'services/users/find_user_class'

module Sykus

  describe Users::FindUserClass do
    let (:identity) { IdentityTestGod.new } 
    let (:find_user_class) { Users::FindUserClass.new identity }

    let! (:uc) { Factory Users::UserClass, {
      name: '7c',
      grade: 7,
    }}

    let! (:uc2) { Factory Users::UserClass, {
      name: '13Pa',
      grade: 13,
    }}

    context 'permission violations' do
      it 'raises on #all' do
        check_service_permission(:user_classes_read, 
                                 Users::FindUserClass, :all)
      end

      it 'raises on #by_id' do
        check_service_permission(:user_classes_read, 
                                 Users::FindUserClass, :by_id, uc.id)
      end
    end

    context 'returns all user classes' do
      subject { find_user_class.all }

      it { should be_a Array }

      it 'returns correct number of user classes' do 
        subject.count.should == 2
      end

      it 'returns correct user class data' do
        subject.should =~ [ uc, uc2 ].map do 
          |uc| find_user_class.by_id uc.id 
        end
      end
    end

    context 'finds user class by id' do
      it 'finds correct user group with all attributes' do
        res = find_user_class.by_id(uc.id)

        res[:id].should == uc.id
        res[:name].should == uc.name
        res[:grade].should == uc.grade
      end

      it 'raises on invalid user class' do
        expect {
          find_user_class.by_id(42000)
        }.to raise_error Exceptions::NotFound
      end
    end

  end

end

