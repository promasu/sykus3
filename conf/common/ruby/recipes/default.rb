package 'libssl1.0.0' do
  version '1.0.1e-3ubuntu1.6'
end

package 'zlib1g' do
  version '1:1.2.8.dfsg-1ubuntu1'
end

package 'libsqlite3-0' do
  version '3.7.17-1ubuntu1'
end

package 'libyaml-0-2' do
  version '0.1.4-2ubuntu0.13.10.3'
end

%w{
  ruby2.0 build-essential zlib1g-dev libssl-doc libssl-dev libsqlite3-dev libyaml-dev
  libxml2-dev libmysqlclient-dev ruby2.0-dev libxslt1-dev ruby-switch
}.each do |name|
  package name do
    action :install
  end
end

execute 'ruby-switch --set ruby2.0'

execute 'gem install bundler' do
  action :run
  not_if { File.exist? '/usr/bin/bundle' }
end

execute 'gem install thor' do
  action :run
  not_if { File.exist? '/usr/bin/thor' }
end



