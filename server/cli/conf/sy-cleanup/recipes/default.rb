# delete old kernels
%x{ls -tr /boot/vmlinuz-* |head -n -1 |cut -d- -f2-}.split("\n").each do |ver|
  %w{linux-image- linux-headers- linux-image-extra-}.each do |prefix|
    package (prefix + ver.strip) do
      action :purge
    end
  end
end

# remove linux header + source packages
Dir['/usr/src/linux-*'].each do |name|
  package File.basename(name) do
    action :purge
  end
end

# this renames eth0 to em1 etc. and confuses our custom network script
package 'biosdevname' do
  action :purge
end

# remove unneeded large packages
%w{
  smbclient samba-common-bin
  software-center update-notifier python3-update-manager app-install-data
}.each do |name|
  package name do
    action :purge
  end
end

# clean apt packages
execute 'apt-get -y --purge autoremove'
execute 'apt-get clean'

# remove all log files
execute 'find /var/log -type f -exec truncate -s 0 {} \;'

# remove apt cache files
execute 'rm -rf /var/cache/apt/* /var/lib/apt/lists/* ' +
  '/var/cache/apt-xapian-index/*'

# remove udev rules
execute 'rm -rf /etc/udev/rules.d/*'

# remove temp files
execute 'rm -rf /var/tmp/* /var/crash/* /tmp/*'

