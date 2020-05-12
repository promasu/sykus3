package 'libnss-db' do
  action :install
end

dir = '/var/lib/sykus3/nssdb' 

directory dir do
  action :create
  owner 'sykus3'
  group 'sykus3'
  mode 0755
  recursive true
end

link '/var/lib/misc/passwd.db' do
  action :create
  link_type :symbolic
  to "#{dir}/users_server.db"
end

link '/var/lib/misc/group.db' do
  action :create
  link_type :symbolic
  to "#{dir}/groups.db"
end

cookbook_file '/etc/nsswitch.conf' do
  action :create
  mode 0644
  source 'nsswitch.conf'
end

