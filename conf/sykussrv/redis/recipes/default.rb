package 'redis-server' do
  action :install
end

service 'redis-server'

cookbook_file '/etc/redis/redis.conf' do
  action :create
  source 'redis.conf'
  mode 0644
  notifies :restart, 'service[redis-server]', :immediately
end



