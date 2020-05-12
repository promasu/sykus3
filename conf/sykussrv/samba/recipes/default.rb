package 'samba' do
  action :install
end

service 'smbd' do
  provider Chef::Provider::Service::Upstart
end

cookbook_file '/etc/samba/smb.conf' do
  action :create
  source 'smb.conf'
  mode 0644
  notifies :restart, 'service[smbd]'
end

