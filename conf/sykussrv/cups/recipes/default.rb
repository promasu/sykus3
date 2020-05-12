%w{
  cups foomatic-db printer-driver-hpcups
}.each do |name|
  package name do
    action :install
  end
end

service 'cups' do
  provider Chef::Provider::Service::Upstart
end

file '/etc/papersize' do
  action :create
  mode 0644
  content "a4\n"
  notifies :restart, 'service[cups]'
end

execute 'cupsctl' do
  action :run
  command 'cupsctl --no-debug-logging --no-remote-admin --no-remote-any ' +
    '--share-printers --no-user-cancel-any ' +
    'Browsing=no BrowseInterval=0 WebInterface=no'
end

