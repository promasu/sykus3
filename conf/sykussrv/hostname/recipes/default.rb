service 'hostname' do
  provider Chef::Provider::Service::Upstart
end

file '/etc/hostname' do
  action :create
  mode 0644
  content data_bag_item('server', 'server')['domain']
  notifies :start, 'service[hostname]', :immediately
end

template '/etc/hosts' do
  source 'hosts.erb'
  mode 0644
  variables domain: data_bag_item('server', 'server')['domain']
  notifies :restart, 'service[pdns-recursor]'
end

