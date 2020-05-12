package 'freeradius' do
  action :install
end

service 'freeradius' do
  provider Chef::Provider::Service::Upstart
end

# dynamic files
%w{clients.conf users}.each do |filename|
  file "/etc/freeradius/#{filename}" do
    action :touch
    user 'sykus3'
    mode 0644
  end
end

%w{radiusd.conf vhost.conf eap.conf}.each do |name|
  cookbook_file "/etc/freeradius/#{name}" do
    action :create
    mode 0644
    source name
    notifies :restart, 'service[freeradius]'
  end
end

# delete cert symlinks because this messes up cert creation below
%w{server.pem server.key ca.pem}.each do |name|
  filename = "/etc/freeradius/certs/#{name}"
  File.unlink filename if File.exists?(filename) && File.symlink?(filename)
end

%w{Makefile xpextensions}.each do |name|
  link "/etc/freeradius/certs/#{name}" do
    action :create
    link_type :symbolic
    to "/usr/share/doc/freeradius/examples/certs/#{name}"
  end
end

%w{ca.cnf server.cnf}.each do |name|
  cookbook_file "/etc/freeradius/certs/#{name}" do
    action :create
    mode 0644
    source name
  end
end

bash 'generate radius certs' do
  action :run

  touchfile = '/etc/freeradius/certs/CERTS_GENERATED' 
  not_if { File.exists? touchfile }

  cwd '/etc/freeradius/certs'

  code <<-EOF
    set -e 
    make
    chmod 0660 *.key *.cnf *.csr Makefile
    chown freerad:freerad *
    mkdir -p public
    cp ca.der ca.pem public
    touch #{touchfile}
    EOF

    notifies :restart, 'service[freeradius]'
end

