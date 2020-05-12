package 'isc-dhcp-server' do
  action :install
end

service 'isc-dhcp-server'

# user gets assigned in snipxe recipe
file '/etc/dhcp/sykus.dynamic.conf' do
  action :touch
  mode 0644
end

template '/etc/dhcp/dhcpd.conf' do
  mode 0644
  source 'dhcpd.conf.erb'
  variables domain: data_bag_item('server', 'server')['domain']
  notifies :restart, 'service[isc-dhcp-server]'
end

cookbook_file '/etc/default/isc-dhcp-server' do
  action :create
  mode 0644
  source 'isc-dhcp-server'
  notifies :restart, 'service[isc-dhcp-server]'
end



