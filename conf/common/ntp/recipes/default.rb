package 'ntp' do
  action :install
end

service 'ntp'

cookbook_file '/etc/ntp.conf' do 
  action :create
  mode 0644
  source 'ntp.conf'
  notifies :restart, 'service[ntp]'
end

