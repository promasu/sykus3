module Sykus; module Config

  # Service permission flags.
  #
  # Be careful when editing permissions. WebIF makes
  # some simplified assumptions about which groups have which
  # permissions.
  module Permissions
    # List of all available permission flags.
    PermissionList = Set.new [
      :common_entity_events,

      :config_edit,

      :users_read,
      :users_write,
      :users_write_admin,
      :users_import,
      :users_password_reset,
      :users_read_password_initial,

      :user_groups_read,
      :user_groups_write,
      :user_groups_write_own,

      :user_classes_read,
      :user_classes_write,

      :hosts_read,
      :hosts_create,
      :hosts_update_delete,
      :host_groups_read,
      :host_groups_write,

      :packages_read,
      :packages_write,
      :image_create,

      :printers_read,
      :printers_reset,
      :printers_write,

      :webfilter_read,
      :webfilter_write,

      :logs_read,

      :teacher_roomctl,
      :teacher_studentpwd,

      :share_teacher_access,
      :share_admin_access,
      :share_progdata_write,

      # Calendar access permissions
      :calendar_teacher_admin,
      :calendar_teacher_write,
      :calendar_teacher_read,
      :calendar_grade_admin,
      :calendar_grade_write,
      :calendar_grade_read,
      :calendar_global_admin,
      :calendar_global_write,
      :calendar_group_admin,
      :calendar_class_admin,
      :calendar_class_write,
      :calendar_class_read,
      :calendar_resource_admin,
      :calendar_resource_write,
      :calendar_resource_read,

      # Calendar resource write/read
      :cal_resource_write,
      :cal_resource_read,
    ]

    # Regular person permissions (neither student nor teacher).
    PositionPerson = Set.new [
      :common_entity_events,
      :user_classes_read,
      :user_groups_read,
    ]

    # Student permissions.
    PositionStudent = Set.new PositionPerson + [
    ]

    # Teacher permissions.
    PositionTeacher = Set.new PositionPerson + [
      :user_groups_write_own,
      :printers_reset,

      :users_read,
      :host_groups_read,
      :teacher_roomctl,
      :teacher_studentpwd,

      :share_teacher_access,

      :calendar_grade_write,
      :calendar_class_write,
      :calendar_global_write,
      :calendar_teacher_write,
      :calendar_resource_write,

      :cal_resource_read,
    ]


    # No admin permissions.
    AdminNone = Set.new [ ]

    # Junior admin permissions.
    AdminJunior = Set.new [
      :users_read,
      :hosts_read,
      :hosts_create,
      :host_groups_read,
      :packages_read,
      :printers_read,
      :webfilter_read,
      :logs_read,

      :share_admin_access,
      :share_progdata_write,

      :calendar_resource_read,
      :cal_resource_read,
    ]

    # Senior admin permissions.
    AdminSenior = Set.new AdminJunior + [
      :users_write,
      :users_import,
      :users_password_reset,
      :users_read_password_initial,
      :user_groups_write_own,
      :user_groups_write,
      :user_classes_write,
      :hosts_update_delete,
      :host_groups_write,
      :packages_write,
      :image_create,
      :printers_read,
      :printers_reset,
      :printers_write,
      :webfilter_write,
      :teacher_roomctl,
      :teacher_studentpwd,

      :calendar_grade_admin,
      :calendar_group_admin,
      :calendar_class_admin,
      :calendar_global_admin,
      :calendar_teacher_admin,
      :calendar_resource_admin,

      :cal_resource_write,
    ]

    # Super admin permissions
    AdminSuper = Set.new AdminSenior + [
      :config_edit,
      :users_write_admin,
      :share_teacher_access,
    ]
  end

end; end

