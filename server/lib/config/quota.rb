module Sykus; module Users

  # Config for quota calculation.
  module QuotaConfig
    # Teachers should get n times more space than students.
    TEACHER_STUDENT_SPACE_FACTOR = 3

    # There are n students for each teacher.
    STUDENT_TEACHER_RATIO = 8

    # Senior or super admins get n quota of total disk space.
    ADMIN_TOTAL_SPACE_FRACTION = 0.2

    # Only assign quotas that are multiples of n.
    QUOTA_STEP = 100

    # Only assign n of total disk space total.
    QUOTA_MAX_ALLOCATION = 0.9

    # Only allow maximum n times calculated space when disks are empty.
    MAX_OVERALLOCATION = 5

    # Minimum space that should be available after quota reduction (in MB).
    MIN_FREE_SPACE = 50

    # Quota block size (hardcoded in sys/mount.h)
    BLOCK_SIZE = 1024
    end

end; end

