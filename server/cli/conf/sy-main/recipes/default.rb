require 'json'

include_recipe 'sy-apt::upgrade'

directory '/var/lib/sykus3/skel' do
  action :create
  mode 0600
  recursive true
end

include_recipe 'sy-sysfiles::default'
include_recipe 'sy-desktop::default'
include_recipe 'sy-lightdm::default'
include_recipe 'sy-login::default'
include_recipe 'sy-ssh::default'
include_recipe 'sy-daemon::default'
include_recipe 'sy-proxychains::default'
include_recipe 'sy-chromium::default'

include_recipe 'sy-packages-apt::default'

JSON.parse(File.read('/tmp/conf/cookbooks.json')).each do |name|
  include_recipe "#{name}::default"
end

# install lilo *after* all other packages
# to prevent initramfs-tools post-hook from failing
# because of sda being vda in VM env
include_recipe 'sy-lilo::default'

include_recipe 'sy-localepurge::default'

# sy-cleanup is in different run-list to get accurate package information

