module Sykus; module Users

  # Dynamically calculates quota values for user position groups
  # depending on user count, disk size and free disk space.
  module CalculateQuotas
    include QuotaConfig

    # Returns data for students, teachers and admins.
    # Admins are senior-admins or above. Persons are treated like teachers.
    # @param [Integer] user_count Number of users in system.
    # @param [Integer] free_space_mb Free disk space in /home (in MB).
    # @param [Integer] total_space_mb Total disk space in /home (in MB).
    # @return [Hash] Hash consisting of quota (in MB) for each user position.
    def self.get(user_count, free_space_mb, total_space_mb)
      # Each teachers counts as STUDENT_TEACHER_RATIO users.

      # students
      weighted_user_count = 
        STUDENT_TEACHER_RATIO.to_f / (STUDENT_TEACHER_RATIO + 1) 

      # teachers
      weighted_user_count += 
        (1.0 / (STUDENT_TEACHER_RATIO + 1)) * TEACHER_STUDENT_SPACE_FACTOR

      weighted_user_count *= user_count

      space = total_space_mb / weighted_user_count * QUOTA_MAX_ALLOCATION

      # prevent div0
      used_space_mb = [ 1, total_space_mb - free_space_mb ].max

      # stick to quota if disk is full, give more space if disk is empty
      space *= [ (total_space_mb / used_space_mb), MAX_OVERALLOCATION ].min

      # assume there are only a few admins that can take care of 
      # what they do with their quota, so give them lots of space
      admin_space = ADMIN_TOTAL_SPACE_FRACTION * total_space_mb

      {
        student: normalize(space),
        teacher: normalize(space * TEACHER_STUDENT_SPACE_FACTOR),
        admin: normalize(admin_space),
      }
      end

      private
      def self.normalize(value)
        (value / QUOTA_STEP.to_f).round * QUOTA_STEP
      end
    end

  end; end

