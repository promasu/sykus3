directory '/home/sykus3' do
  action :create
  mode 0755
  recursive true
end

%w{cache data dist}.each do |name|
  directory '/home/sykus3/' + name do
    action :create
  end
end

%w{
  sykus-build sykus-deploy
  blacklists/build.sh
  sni/build.sh
  webif/download_libs.sh
  webif/build.sh
  webif/js_build.sh
}.each do |name|
  file '/home/sykus3/build/' + name do
    mode 0755
  end
end

cookbook_file '/etc/profile.d/sykus3.sh' do
  action :create
  mode 0644
  source 'sykus3.sh'
end


