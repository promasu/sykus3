cookbook_file '/etc/firewall.sh' do
  action :create
  mode 0755
  source 'firewall.sh'
  notifies :restart, 'service[firewall]'
end

cookbook_file '/etc/init/firewall.conf' do
  action :create
  mode 0644
  source 'firewall.conf'
  notifies :restart, 'service[firewall]'
end

service 'firewall' do
  provider Chef::Provider::Service::Upstart
  action :start
  supports restart: false, status: true
end

