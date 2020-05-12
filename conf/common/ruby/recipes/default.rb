%w{
  ruby2.0 build-essential libssl-dev libssl1.0.0=1.0.1-3ubuntu1.6 zlib1g-dev libssl-doc libsqlite3-dev libyaml-dev
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



