require 'common'

module Sykus; module Users

  # Updates or creates group share directories and symlinks.
  class UpdateGroupSharesJob
    extend Resque::Plugins::Queue::Lock
    extend Resque::Plugins::Workers::Lock
    @queue = :fast

    # Group directory base.
    GROUP_DIR = '/home/groups'

    # Runs the job.
    def self.perform
      system "sudo touch #{GROUP_DIR}/.touchfile"

      Users::UserGroup.each do |group|
        group_dir = "#{GROUP_DIR}/.g#{group.id}"
        symlink = "#{group.name} - #{group.owner.full_name.to_s} (#{group.id})"
        link_path = "#{GROUP_DIR}/#{Shellwords.shellescape symlink}"

        system "sudo mkdir -p #{group_dir}"
        system "sudo touch #{group_dir}"

        system "sudo chmod 2770 #{group_dir}"
        system "sudo chown sykus3:#{group.system_id} #{group_dir}"

        system "sudo ln -sf #{File.basename group_dir} #{link_path}"
        system "sudo touch -h #{link_path}"
        system "sudo chown -h sykus3:#{group.system_id} #{link_path}"
      end

      # delete all old symlinks
      system "sudo find #{GROUP_DIR} -type l -mindepth 1 -maxdepth 1 " +
        "! -newer #{GROUP_DIR}/.touchfile -exec rm -f {} \\;"
    end
  end

end; end

