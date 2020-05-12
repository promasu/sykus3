cookbook_file '/etc/apt/apt.conf.d/42sykus' do
  action :create
  source 'dpkg.conf'
  mode 0644

  notifies :delete, 'file[touchfile]', :immediately
end

cookbook_file '/etc/apt/sources.list' do
  action :create
  source 'sources.list'
  mode 0644

  notifies :delete, 'file[touchfile]', :immediately
end

touchfile = '/var/lib/apt/sykus_touchfile'

file 'touchfile' do
  path touchfile
  action :nothing
end

update_block = bash 'update' do
  action :nothing
  code <<-EOF
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get -y dist-upgrade
    apt-get -y --purge autoremove
    apt-get clean

    which gem && gem update

    touch #{touchfile}
    EOF
end

# run now so package cache is current before chef gets package version info
# checking for updates every hour is enough
if !File.exists?(touchfile) || Time.now - File.mtime(touchfile) > 3600
  update_block.run_action :run
end

