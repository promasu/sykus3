package 'pdns-recursor' do
  action :install
end

service 'pdns-recursor' 

cookbook_file '/etc/powerdns/recursor.conf' do
  source 'recursor.conf'
  notifies :restart, 'service[pdns-recursor]'
end

