require 'spec_helper'

require 'services/users/find_user_group'

module Sykus

  describe Users::FindUserGroup do
    let (:identity) { IdentityTestGod.new } 
    let (:find_user_group) { Users::FindUserGroup.new identity }

    let (:owner) { Factory Users::User }
    let (:owner2) { Factory Users::User }
    let (:member) { Factory Users::User }

    let! (:ug) { Factory Users::UserGroup, {
      name: 'Good Guys',
      owner: owner,
      users: [ owner, member ],
    }}

    let! (:ug2) { Factory Users::UserGroup, {
      name: 'Other Guys',
      owner: owner2,
      users: [ member ],
    }}

    context 'permission violations' do
      it 'raises on #all' do
        check_service_permission(:user_groups_read, 
                                 Users::FindUserGroup, :all)
      end

      it 'raises on #by_id' do
        check_service_permission(:user_groups_read, 
                                 Users::FindUserGroup, :by_id, 42)
      end

      it 'raises on #own' do
        check_service_permission(:user_groups_read, 
                                 Users::FindUserGroup, :own)
      end 
    end

    context 'returns all user groups' do
      subject { find_user_group.all }

      it { should be_a Array }

      it 'returns correct number of user groups' do 
        subject.count.should == 2
      end

      it 'returns correct user group data' do
        subject.should =~ [ ug, ug2 ].map do 
          |ug| find_user_group.by_id ug.id 
        end
      end
    end

    context 'finds user group by id' do
      it 'finds correct user group with all attributes' do
        res = find_user_group.by_id(ug.id)

        res[:id].should == ug.id
        res[:name].should == ug.name
        res[:owner].should == owner.id
        res[:users].should =~ [ owner.id, member.id ]
      end

      it 'raises on invalid user group' do
        expect {
          find_user_group.by_id(42000)
        }.to raise_error Exceptions::NotFound
      end
    end

    context 'finds own user groups' do
      it 'returns correct groups' do
        identity.user_id = owner.id
        find_user_group.own.should == [ find_user_group.by_id(ug.id) ]
      end

      it 'raises if no user identity is given' do
        expect { find_user_group.own }.to raise_error Exceptions::Input
      end
    end
  end

end

