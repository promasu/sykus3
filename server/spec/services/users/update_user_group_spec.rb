require 'spec_helper'

require 'services/users/update_user_group'
require 'jobs/users/update_group_shares_job'
require 'jobs/users/create_nss_db_job'

module Sykus

  describe Users::UpdateUserGroup do
    let (:identity) { IdentityTestGod.new } 
    let (:update_user_group) { Users::UpdateUserGroup.new identity } 

    let (:owner) { Factory Users::User }
    let (:newowner) { Factory Users::User }
    let (:member) { Factory Users::User }

    let (:ug) { Factory Users::UserGroup, owner: owner }

    let (:goodguys) {{
      name: 'Good Guys',
      owner: newowner.id,
      users: [ member.id ],
    }}

    context 'input parameters' do
      it 'works with all attributes' do
        update_user_group.run(ug.id, goodguys)

        ref = Users::UserGroup.get ug.id
        ref.name.should == goodguys[:name]
        ref.owner.should == newowner 
        ref.users.should =~ [ newowner, member ]

        check_entity_evt(EntitySet.new(Users::UserGroup), ug.id, false)
        Resque.dequeue(Users::UpdateGroupSharesJob).should == 1
        Resque.dequeue(Users::CreateNSSDBJob).should == 1
      end

      it 'handles owner change correctly' do
        update_user_group.run(ug.id, { users: [ member.id ] })
        update_user_group.run(ug.id, { owner: newowner.id })

        ref = Users::UserGroup.get ug.id
        ref.owner.should == newowner 
        ref.users.should =~ [ owner, newowner, member ]
      end

      it 'works with empty data' do
        ref = Users::UserGroup.get(ug.id).to_json
        update_user_group.run(ug.id, {})

        Users::UserGroup.get(ug.id).to_json.should == ref
      end

      it 'works with duplicate members' do
        data = { users: [ member.id, member.id, owner.id, member.id ] }
        update_user_group.run(ug.id, data)

        Users::UserGroup.get(ug.id).users.should =~ [ member, owner ]
      end
    end

    context 'errors' do
      before :each do 
        identity.user_id = owner.id
      end

      it '#run raises on permission violation (write to foreign group)' do
        check_service_permission(:user_groups_write, 
                                 Users::UpdateUserGroup, :run, ug.id, {})
      end

      it 'raises on own-write permission violation' do
        identity.permission_table.set(:user_groups_write_own, false)

        expect { 
          update_user_group.run(ug.id, { owner: owner.id })
        }.to raise_error Exceptions::Permission
      end

      it 'raises on owner change if only own-write permission present' do
        identity.permission_table.set(:user_groups_write, false)

        expect { 
          update_user_group.run(ug.id, { owner: member.id })
        }.to raise_error Exceptions::Permission
      end
    end
  end

end

