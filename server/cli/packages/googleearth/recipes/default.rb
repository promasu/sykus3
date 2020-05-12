# REVIEW: url current?
download_url = 'http://dl.google.com/' + 
  'dl/earth/client/current/google-earth-stable_current_i386.deb' 

directory '/tmp/googleearth' do
  action :create
end

remote_file '/tmp/googleearth/earth.deb' do
  action :create
  source download_url
end

package 'lsb-core' do
  action :install
end

dpkg_package 'googleearth' do
  action :install
  source '/tmp/googleearth/earth.deb'
end

cookbook_file '/opt/google/earth/free/googleearth' do
  action :create
  mode 0755
  source 'googleearth'
end

directory '/var/lib/sykus3/skel/.config/Google' do
  action :create
  mode 0755
  recursive true
end

cookbook_file '/var/lib/sykus3/skel/.config/Google/GoogleEarthPlus.conf' do
  action :create
  mode 0644
  source 'GoogleEarthPlus.conf'
end


