require 'spec_helper'

require 'services/users/create_user_group'
require 'jobs/users/update_group_shares_job'
require 'jobs/users/create_nss_db_job'

module Sykus

  describe Users::CreateUserGroup do
    let (:identity) { IdentityTestGod.new } 
    let (:create_user_group) { Users::CreateUserGroup.new identity }

    let (:owner) { Factory Users::User }
    let (:member) { Factory Users::User }

    let (:goodguys) {{
      name: 'Good Guys',
      owner: owner.id,
      users: [ member.id ],
    }}

    subject { create_user_group.run goodguys }

    def check(result)
      id = result[:id]
      id.should be_a Integer

      ug = Users::UserGroup.get id
      ug.name.should == goodguys[:name]
      ug.owner.should == owner
      ug.users.should =~ [ owner, member ]

      check_entity_evt(EntitySet.new(Users::UserGroup), id, false)
      Resque.dequeue(Users::UpdateGroupSharesJob).should == 1
      Resque.dequeue(Users::CreateNSSDBJob).should == 1
    end

    it 'works with all required parameters' do
      check subject
    end

    it 'works with owner explicitly in member list' do
      goodguys[:users] = [ member.id, owner.id ]
      check subject
    end

    context 'errors' do
      it '#run raises on permission violation' do
        check_service_permission(:user_groups_write, 
                                 Users::CreateUserGroup, :run, goodguys)
      end

      it 'raises on own-write permission violation' do
        identity.user_id = owner.id
        identity.permission_table.set(:user_groups_write_own, false)

        expect { subject }.to raise_error Exceptions::Permission
      end

      [ :name, :owner, :users ].each do |element|
        it "raises if #{element} is missing" do
          goodguys.delete element

          expect { subject }.to raise_error Exceptions::Input
        end
      end
    end
  end

end

