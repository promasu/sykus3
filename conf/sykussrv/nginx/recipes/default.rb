package 'nginx-full' do
  action :install
end

service 'nginx' 

cookbook_file '/etc/nginx/nginx.conf' do
  action :create
  source 'nginx.conf'
  notifies :restart, 'service[nginx]'
end

directory '/etc/nginx/ssl' do
  action :create
  user 'www-data'
  mode 0600
end

file '/etc/nginx/ssl/cert.pem' do
  action :create
  user 'www-data'
  mode 0600
  content data_bag_item('server', 'server')['ssl_cert']
  notifies :restart, 'service[nginx]'
end

file '/etc/nginx/ssl/cert.key' do
  action :create
  user 'www-data'
  mode 0600
  content data_bag_item('server', 'server')['ssl_key']
  notifies :restart, 'service[nginx]'
end

template '/etc/nginx/conf.d/sykus.conf' do
  action :create
  source 'sykus.conf.erb'
  variables domain: data_bag_item('server', 'server')['domain']
  notifies :restart, 'service[nginx]'
end


