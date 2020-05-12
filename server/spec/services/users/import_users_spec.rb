require 'spec_helper'

require 'services/users/import_users'

module Sykus

  describe Users::ImportUsers do
    let (:import_users) { Users::ImportUsers.new IdentityTestGod.new }

    let (:class_7c) { Factory Users::UserClass, name: '7c', grade: 7 }
    let (:class_8b) { Factory Users::UserClass, name: '8b', grade: 8 }

    context 'with 4 students present' do
      before :each do
        Factory Users::User, username: 'meierhans', birthdate: '16.08.1990',
          full_name: Users::FullUserName.new('Hans', 'Meier'), 
          user_class: class_7c, position_group: :student
        Factory Users::User, username: 'schulzjan', birthdate: '05.05.1992',
          full_name: Users::FullUserName.new('Jan', 'Schulz'), 
          user_class: class_7c, position_group: :student
        Factory Users::User, username: 'berglisa', birthdate: '11.05.1991',
          full_name: Users::FullUserName.new('Lisa', 'Berg'), 
          user_class: class_8b, position_group: :student
        Factory Users::User, username: 'dreyertom', birthdate: '01.01.1991',
          full_name: Users::FullUserName.new('Tom', 'Dreyer'), 
          user_class: class_8b, position_group: :student
      end

      def data
        [
          # no change
          'Meier;Hans;16.08.1990;7c',

          # changed class
          'Schulz;Jan;05.05.1992;9b',

          # new user with same name (but different birthdate)
          'Schulz;Jan;01.02.1993;8b',

          # user not present anymore
          # (berglisa)

          # new user that has one user with same
          # username who is going to be deleted
          'Dreyer;Tom;02.02.1992;8b',

          # new user
          'Schmidt;Pia;07.09.1991;7c',

        ].join "\n"
      end

      [ true, false ].each do |confirm_on|
        [ true, false ].each do |delete_on|
          it "works with delete #{delete_on} and confirm #{confirm_on}" do
            users_before = Users::User.all.to_json

            result = import_users.run({
              delete: delete_on,
              confirm: confirm_on,
              data: data,
              type: :student,
            })[:result]

            Users::User.all.should == Users::User.all(position_group: :student)

            class_9b = Users::UserClass.first name: '9b'

            if confirm_on
              class_9b.should_not be_nil

              hansmeier = Users::User.all first_name: 'Hans', 
                last_name: 'Meier'
              hansmeier.count.should == 1
              hansmeier.first.username.should == 'meierhans'
              hansmeier.first.birthdate.should == '16.08.1990'
              hansmeier.first.user_class.should == class_7c

              schulzjan1 = Users::User.all first_name: 'Jan', 
                last_name: 'Schulz', birthdate: '05.05.1992'
              schulzjan1.count.should == 1
              schulzjan1.first.username.should == 'schulzjan'
              schulzjan1.first.user_class.should == class_9b

              schulzjan = Users::User.all first_name: 'Jan',
                last_name: 'Schulz'
              schulzjan.count.should == 2

              schulzjan2 = Users::User.all first_name: 'Jan', 
                last_name: 'Schulz', birthdate: '01.02.1993'
              schulzjan2.count.should == 1
              schulzjan2.first.username.should == 'schulzjan1'
              schulzjan2.first.user_class.should == class_8b

              dreyertom = Users::User.all first_name: 'Tom', 
                last_name: 'Dreyer'

              if delete_on
                dreyertom.count.should == 1
                dreyertom.first.birthdate.should == '02.02.1992'
                dreyertom.first.username.should == 'dreyertom'
              else
                dreyertom.count.should == 2

                dreyertom.all({
                  birthdate: '01.01.1991', 
                  username: 'dreyertom',
                }).count.should == 1

                dreyertom.all({
                  birthdate: '02.02.1992', 
                  username: 'dreyertom1',
                }).count.should == 1
              end

              berglisa = Users::User.all first_name: 'Lisa', 
                last_name: 'Berg'
              berglisa.count.should == (delete_on ? 0 : 1)

              schmidtpia = Users::User.all first_name: 'Pia', 
                last_name: 'Schmidt'
              schmidtpia.count.should == 1
              schmidtpia.first.username.should == 'schmidtpia'
              schmidtpia.first.birthdate.should == '07.09.1991'
              schmidtpia.first.user_class.should == class_7c

              Users::User.count.should == (delete_on ? 5 : 7)
            else
              class_9b.should be_nil

              Users::User.all.count.should == 4

              # parse to make nice diff on test fail
              JSON.parse(Users::User.all.to_json).should == 
                JSON.parse(users_before)
            end

            result.should be_a Array

            result.should include({ 
              status: :updated, 
              first_name: 'Jan',
              last_name: 'Schulz', 
              birthdate: '05.05.1992',
              user_class: '9b',
            })

            result.should include({ 
              status: :new, 
              first_name: 'Jan',
              last_name: 'Schulz', 
              birthdate: '01.02.1993',
              user_class: '8b',
            })

            result.should include({ 
              status: :new, 
              first_name: 'Tom',
              last_name: 'Dreyer', 
              birthdate: '02.02.1992',
              user_class: '8b',
            })

            if delete_on 
              result.should include({ 
                status: :deleted, 
                first_name: 'Lisa',
                last_name: 'Berg', 
                birthdate: '11.05.1991',
                user_class: '8b',
              })
              result.should include({ 
                status: :deleted, 
                first_name: 'Tom',
                last_name: 'Dreyer', 
                birthdate: '01.01.1991',
                user_class: '8b',
              })
            end

            result.should include({ 
              status: :new, 
              first_name: 'Pia',
              last_name: 'Schmidt', 
              birthdate: '07.09.1991',
              user_class: '7c',
            })
            result.count.should == (delete_on ? 6 : 4)
          end
        end
      end
    end

    context 'with 1 teacher present' do
      before :each do
        Factory Users::User, username: 'meierhans', birthdate: '16.08.1970',
          full_name: Users::FullUserName.new('Hans', 'Meier'), 
          user_class: nil, position_group: :teacher

        Factory Users::User, username: 'dreyertom', birthdate: '01.01.1971',
          full_name: Users::FullUserName.new('Tom', 'Dreyer'), 
          user_class: nil, position_group: :teacher
      end

      def data
        [
          # no change
          'Meier;Hans;16.08.1970',

          # new user
          'Schmidt;Pia;07.09.1971',

          # user not present anymore
          # (dreyertom)

        ].join "\n"
      end

      # we do not test delete off here, this is covered by student test
      [ true, false ].each do |confirm_on|
        it "works with delete true and confirm #{confirm_on}" do
          users_before = Users::User.all.to_json

          result = import_users.run({
            delete: true,
            confirm: confirm_on,
            data: data,
            type: :teacher,
          })[:result]

          Users::User.all.should == Users::User.all(position_group: :teacher)

          if confirm_on
            hansmeier = Users::User.all first_name: 'Hans', 
              last_name: 'Meier'
            hansmeier.count.should == 1
            hansmeier.first.username.should == 'meierhans'
            hansmeier.first.birthdate.should == '16.08.1970'
            hansmeier.first.user_class.should == nil

            schmidtpia = Users::User.all first_name: 'Pia', 
              last_name: 'Schmidt'
            schmidtpia.count.should == 1
            schmidtpia.first.username.should == 'schmidtpia'
            schmidtpia.first.birthdate.should == '07.09.1971'
            schmidtpia.first.user_class.should == nil

            dreyertom = Users::User.all first_name: 'Tom', last_name: 'Dreyer'
            dreyertom.count.should == 0

            Users::User.all.count.should == 2
          else
            Users::User.all.count.should == 2
          end

          result.should be_a Array

          result.should include({ 
            status: :new, 
            first_name: 'Pia',
            last_name: 'Schmidt', 
            birthdate: '07.09.1971',
            user_class: nil,
          })

          result.should include({ 
            status: :deleted, 
            first_name: 'Tom',
            last_name: 'Dreyer', 
            birthdate: '01.01.1971',
            user_class: nil,
          })

          result.count.should == 2
        end
      end
      end

      it 'does not delete users with admin flag' do
        user = Factory Users::User, admin_group: :junior

        import_users.run({
          delete: true,
          confirm: true,
          type: :student,
          data: '',
        })

        Users::User.get(user.id).should_not be_nil
      end 

      it 'deletes empty user classes' do
        Factory Users::UserClass

        import_users.run({
          delete: true,
          confirm: true,
          type: :student,
          data: '',
        })

        Users::UserClass.all.count.should == 0
      end


      context 'errors' do
        it '#run raises on permission violation' do
          check_service_permission(:users_import, Users::ImportUsers, :run, {})
        end

        it 'raises on invalid input' do
          expect do
            import_users.run({
              type: :student,
              data: 'Berg;Lisa;05.05.1991;'
            })
          end.to raise_error Exceptions::Input
        end

        it 'raises on invalid type' do
          expect do
            import_users.run({
              type: :test,
              data: 'Berg;Lisa;05.05.1991;7c'
            })
          end.to raise_error Exceptions::Input
        end

      end
    end

  end

