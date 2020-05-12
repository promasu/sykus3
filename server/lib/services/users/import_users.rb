require 'common'


require 'services/users/create_user'
require 'services/users/create_user_class'
require 'services/users/update_user'
require 'services/users/delete_user'
require 'services/users/delete_user_class'

module Sykus; module Users

  # Imports new users, updates existing users and deletes old users.
  class ImportUsers < ServiceBase

    def initialize(identity)
      super
      @create_user = CreateUser.new identity
      @create_user_class = CreateUserClass.new identity
      @update_user = UpdateUser.new identity
      @delete_user = DeleteUser.new identity
      @delete_user_class = DeleteUserClass.new identity
    end

    # @param [Hash] args Hash with data string and delete flag.
    # @return [Hash] Hash with changed user data.
    def run(args)
      enforce_permission! :users_import

      data = args[:data]
      raise Exceptions::Input, 'Invalid data' unless data.is_a? String

      confirm = !!args[:confirm]
      delete = !!args[:delete]

      raise Exceptions::Input, 'Invalid type' if args[:type].nil?
      type = args[:type].to_sym
      unless [ :teacher, :student ].include? type 
        raise Exceptions::Input, 'Invalid type'
      end

      result, processed, id_list = [], [], []

      data.strip.split("\n").each do |line|
        sp = line.split(';')
        if sp.length != (type == :teacher ? 3 : 4)
          raise Exceptions::Input, 'Invalid user line'
        end

        user = {
          last_name: sp[0].strip,
          first_name: sp[1].strip,
          birthdate: sp[2].strip,
        }
        raise Exceptions::Input, 'Duplicate user' if processed.include? user
        processed << user

        ref = User.first user
        id_list << ref.id if ref

        # merge user class after processed user check and reference get
        # because user class can change
        user.merge!({ user_class: type == :student ? sp[3].strip : nil }) 

        # updated user class
        if ref && type == :student && ref.user_class.name != user[:user_class]
          result << user.merge({ 
            status: :updated, 
            user_class: user[:user_class] 
          })

          if confirm
            @update_user.run ref.id, 
              user_class: get_user_class(type, user[:user_class])
          end
        end

        # new user
        result << user.merge({ status: :new }) unless ref
      end

      if delete
        User.all({
          :position_group => type, 
          :id.not => id_list,
          :admin_group => :none
        }).each do |user|
          result << ({
            status: :deleted,
            last_name: user.full_name.last_name,
            first_name: user.full_name.first_name,
            birthdate: user.birthdate,
            user_class: (type == :student ? user.user_class.name : nil),
          })
          @delete_user.run user.id if confirm
        end
      end

      # create users outside of the first loop
      # to allow users with the same username to be deleted first
      if confirm
        result.each do |user|
          next unless user[:status] == :new

          username = GenerateUsername.run \
            FullUserName.new(user[:first_name], user[:last_name])

          @create_user.run(user.merge({
            username: username,
            user_class: get_user_class(type, user[:user_class]),
            position_group: type,
            admin_group: :none,
          }))
        end
      end

      if delete && confirm && type == :student
        UserClass.all(users: nil).each do |uc|
          @delete_user_class.run uc.id
        end
      end

      { result: result }
    end

    private 
    def get_user_class(type, name)
      return nil unless type == :student
      (UserClass.first(name: name) || @create_user_class.run(name: name))[:id]
    end

  end

end; end

