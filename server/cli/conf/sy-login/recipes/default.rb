%w{
  libpam-script libnss-db ruby cifs-utils nscd davfs2
}.each do |name|
  package name do
    action :install
  end
end

# this breaks logout and we don't need it
package 'gnome-keyring' do
  action :purge
end

cookbook_file '/etc/nscd.conf' do
  action :create
  mode 0644
  source 'nscd.conf'
end

cookbook_file '/etc/pam.d/lightdm' do
  action :create
  mode 0644
  source 'lightdm.pam'
end

cookbook_file '/etc/nsswitch.conf' do
  action :create
  mode 0644
  source 'nsswitch.conf'
end

directory '/usr/lib/sykus3/pam' do
  action :create
  recursive true
  mode 0700
end

cookbook_file '/usr/lib/sykus3/pam/pam_script_auth' do
  action :create
  mode 0755
  source 'pam_script_auth'
end

cookbook_file '/usr/lib/sykus3/pam/pam_script_ses_open' do
  action :create
  mode 0755
  source 'pam_script_ses_open'
end

cookbook_file '/usr/lib/sykus3/pam/pam_script_ses_close' do
  action :create
  mode 0755
  source 'pam_script_ses_close'
end

cookbook_file '/etc/davfs2/davfs2.conf' do
  action :create
  mode 0644
  source 'davfs2.conf'
end

user 'localuser' do
  action :create
  home '/home/localuser'
  # REVIEW: i18n
  comment 'Lokaler Login'
  shell '/bin/bash'
  supports manage_home: true
end

