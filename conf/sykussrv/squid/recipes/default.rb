package 'squid3' do
  action :install
end

package 'squidguard' do
  action :install
end

service 'squid3' do
  provider Chef::Provider::Service::Upstart
end

cookbook_file '/etc/squid3/squid.conf' do
  action :create
  mode 0644
  source 'squid.conf'
  notifies :restart, 'service[squid3]'
end

cookbook_file '/etc/squid3/wpad.dat' do
  action :create
  mode 0644
  source 'wpad.dat'
end

cookbook_file '/etc/squidguard/compile.conf' do
  action :create
  mode 0644
  source 'compile.conf'
end

cookbook_file '/etc/squidguard/webfilter.conf' do
  action :create
  mode 0644
  source 'webfilter.conf'
  notifies :restart, 'service[squid3]'
end


directory '/var/lib/sykus3/blacklists' do
  action :create
  owner 'sykus3'
  group 'sykus3'
  recursive true
end

file '/var/lib/sykus3/blacklists/nonstudents.list' do
  action :touch
  owner 'sykus3'
  group 'sykus3'
  mode 0644
end

blacklist_dir = '/var/lib/sykus3/blacklists/vendor'

directory blacklist_dir do
  action :create
  owner 'sykus3'
  group 'sykus3'
  recursive true
end

bash 'extract blacklists' do
  user 'sykus3'
  group 'sykus3'
  cwd blacklist_dir
  verfile = "blacklists.tgz.version"
  code <<-EOF
    rm -rf *
    tar -xzf /usr/lib/sykus3/dist/blacklists.tgz
    cp /usr/lib/sykus3/dist/#{verfile} .
  EOF

  not_if do 
    Dir.exists?("#{blacklist_dir}/#{verfile}") && 
    (File.read("#{blacklist_dir}/#{verfile}") == 
     File.read('/usr/lib/sykus3/dist/' + verfile))
  end
end


