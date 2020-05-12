package 'openssh-server' do
  action :install
end

service 'ssh' do
  provider Chef::Provider::Service::Upstart
end

cookbook_file '/etc/ssh/sshd_config' do
  action :create
  mode 0644
  source 'sshd_config'
  notifies :restart, 'service[ssh]'
end

