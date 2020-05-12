user 'sykus3' do
  action :create
  shell '/bin/bash'
  home '/var/lib/sykus3'
  system true
  supports manage_home: true
end

group 'users' do
  action :create
  gid 100
  group_name 'users'
end

%w{kvm libvirtd redis}.each do |name|
  group name do
    action :modify
    members 'sykus3'
    append true
  end
end

directory '/usr/lib/sykus3/dist' do
  action :create
  recursive true
  owner 'sykus3'
  group 'sykus3'
  mode 0700
end

[ '/var/lib/sykus3', '/var/lib/sykus3/run' ].each do |name|
  directory name do
    action :create
    recursive true
    owner 'sykus3'
    group 'sykus3'
    mode 0755
  end
end

cookbook_file '/etc/sudoers.d/sykus3' do
  action :create
  source 'sudofile'
end

