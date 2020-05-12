package 'resolvconf' do
  action :purge
end

cookbook_file '/etc/dhcp/dhclient-enter-hooks' do
  action :create
  mode 0644
  source 'dhclient-enter-hooks'
end

cookbook_file '/etc/resolv.conf' do
  action :create
  mode 0644
  source 'resolv.conf'
end

