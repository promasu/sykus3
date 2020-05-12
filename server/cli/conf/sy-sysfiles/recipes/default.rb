require 'shellwords'

%w{fstab hosts}.each do |name|
  cookbook_file "/etc/#{name}" do
    action :create
    mode 0644
    source name
  end
end

package 'ifenslave' do
  action :install
end

template '/etc/sykus_env' do
  action :create
  mode 0644
  variables domain: data_bag_item('client', 'client')['server_domain']
  source 'sykus_env.erb'
end

cookbook_file '/etc/network/interfaces' do
  action :create
  mode 0644
  source 'interfaces'
end

cookbook_file '/etc/init/sykus3-net.conf' do
  action :create

  # do not reveal our secrets ;)
  mode 0600
  source 'sykus3-net.conf'
end

template '/etc/wlan.conf' do
  action :create
  mode 0600
  source 'wlan.conf.erb'

  data_bag = data_bag_item('client', 'client')
  ssid = data_bag['wlan_ssid'] || ''
  key = data_bag['wlan_key'] || ''
  password = data_bag['radius_client_password'] || ''

  variables ssid: ssid, key: key, password: password
end

file '/etc/radius_ca.pem' do
  action :create
  mode 0644
  content data_bag_item('client', 'client')['radius_ca']
end

cookbook_file '/etc/default/ntpdate' do
  action :create
  mode 0644
  source 'ntpdate'
end


