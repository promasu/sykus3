%w{
  curl ruby bundler imagemagick x11vnc vncsnapshot nginx unclutter
  cups
}.each do |name|
  package name do
    action :install
  end
end

directory '/usr/lib/sykus3/daemon' do
  action :create
  mode 0700
  recursive true
end

directory '/var/lib/sykus3/screenshot' do
  action :create
  mode 0755
  recursive true
end

cookbook_file '/etc/nginx/nginx.conf' do
  action :create
  mode 0644
  source 'nginx.conf'
end

cookbook_file '/etc/init/sykus3-daemon.conf' do
  action :create
  mode 0644
  source 'daemon.conf'
end

cookbook_file '/etc/default/unclutter' do
  action :create
  mode 0644
  source 'unclutter'
end

file '/usr/lib/sykus3/daemon/server_domain' do
  action :create
  mode 0644
  content data_bag_item('client', 'client')['server_domain'] 
end

execute 'bundle install --path .bundle' do
  action :run
  cwd '/usr/lib/sykus3/daemon'
end


