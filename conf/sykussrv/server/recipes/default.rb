server_dir = '/usr/lib/sykus3/server'
target = data_bag_item('server', 'server')['target']
prod = (target == 'prod')

%w{wakeonlan at}.each do |name|
  package name do
    action :install
  end
end

directory server_dir do
  action :create
  owner 'sykus3'
  group 'sykus3'
  mode 0700
end

bash 'extract server' do
  user 'sykus3'
  group 'sykus3'
  cwd server_dir
  verfile = "server_#{target}.tgz.version"
  code <<-EOF
    rm -rf *
    tar -xzf ../dist/server_#{target}.tgz
    cp ../dist/#{verfile} .
  EOF

  not_if do 
    Dir.chdir '/usr/lib/sykus3' do
      File.exists?('server/' + verfile) && 
        File.read('server/' + verfile) == File.read('dist/' + verfile)
    end
  end

  notifies :run, 'execute[bundler]', :immediately
  notifies :run, 'execute[foreman-upstart]', :immediately
  notifies :stop, 'service[sykus3]', :immediately
  notifies :touch, 'file[sykus-tool]', :immediately
  notifies :run, 'execute[postinstall-hook]', :immediately
  notifies :start, 'service[sykus3]', :immediately
end

execute 'bundler' do
  action :nothing
  user 'sykus3'
  cwd server_dir

  # without is a sticky option, so we need to overwrite it
  # if it is empty
  without = prod ? 'test' : 'x'
  command "bundle install --path .bundle --without #{without}" 
end

execute 'foreman-upstart' do
  action :nothing
  cwd server_dir

  procs = {
    'api' => prod ? 4 : 1,
    'webdav' => prod ? 4 : 1,
    'worker-fast' => prod ? 3 : 1,
    'worker-slow' => prod ? 3 : 1,
    'worker-image' => 1,
    'scheduler' => 1,
  }

  command 'bundle exec foreman export upstart /etc/init ' +
    '-a sykus3 -p 5000 -c ' + procs.map { |k,v| "#{k}=#{v}" }.join(',')
end

service 'sykus3' do
  provider Chef::Provider::Service::Upstart
  action :nothing
  supports restart: false, status: true
end

file 'sykus-tool' do
  action :nothing
  path "#{server_dir}/sykus-tool" 
  owner 'sykus3'
  group 'sykus3'
  mode 0755
end

# changing user/group with chef's methods does not work
# since only uid/gid is changed and additional groups are not loaded.
execute 'postinstall-hook' do
  action :nothing
  command "su sykus3 -c '#{server_dir}/sykus-tool postinstall'"
end

