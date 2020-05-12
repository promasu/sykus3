require 'shellwords'

# REVIEW: url current?
download_url = 'http://downloads.smarttech.com/' +
  'software/nb/11linux/smart_software_deb_repo.tar.gz'

# REVIEW: url current?
libudev0_url = 'http://de.archive.ubuntu.com/' + 
  'ubuntu/pool/main/u/udev/libudev0_175-0ubuntu13_i386.deb'

%w{
  gnupg libcurl3 libnspr4-0d
}.each do |name|
  package name do
    action :install
  end
end

directory '/tmp/smart' do
  action :create
end

remote_file '/tmp/smart/archive.tgz' do
  action :create
  source download_url
end

# REVIEW: smart requires libudev0 but ubuntu raring ships libudev1
remote_file '/tmp/smart/libudev0.deb' do
  action :create
  source libudev0_url
end

dpkg_package 'libudev0' do
  action :install
  source '/tmp/smart/libudev0.deb'
end

# SMART Notebook Software breaks if users are not in /etc/passwd 
# (we use libnss-db) but installing nscd prevents crashing. 

bash 'install-smart' do
  action :run
  cwd '/tmp/smart'

  data_bag = data_bag_item('client', 'client')
  product_key = Shellwords.shellescape(data_bag['smartboard_serial'] || '')

  code <<-EOF
  # create default gpg config files
  echo |gpg || true

  tar -xzf archive.tgz
  rm archive.tgz

  source customization
  echo "export SMART_ARCHIVE_KEY=$SMART_ARCHIVE_KEY" > customization
  echo "export NO_SB_AUTOSTART=1" >> customization
  echo "export DISALLOW_DOWNLOAD=1" >> customization

  echo "export PRODUCT_KEY=#{product_key}" >> customization

    find dists -name '*.deb' -exec mv {} . \\;
  ./customize.sh files i386

  dpkg -i smart-*.deb

  # install leaves some config files world writable, this is unacceptable
  chmod -R o-w /opt/SMART* /etc/xdg/SMART* /usr/local/share/macrovision
  EOF
end

# SMART devices files need to be world-read/writable
cookbook_file '/lib/udev/rules.d/99-smartboard.rules' do
  action :create
  mode 0644
  source '99-smartboard.rules'
end

directory '/var/lib/sykus3/skel/.config/autostart' do 
  action :create
  mode 0755
end

# Start SMART Board service on login
cookbook_file '/var/lib/sykus3/skel/.config/autostart/smart.desktop' do
  action :create
  mode 0755
  source 'smart-autostart.desktop'
end

