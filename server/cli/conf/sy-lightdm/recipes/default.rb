package 'lightdm-webkit-greeter' do
  action :install
end

%w{lightdm.conf lightdm-webkit-greeter.conf}.each do |file|
  cookbook_file "/etc/lightdm/#{file}" do
    action :create
  mode 0644
  source file
  end
end

theme_path = '/usr/share/lightdm-webkit/themes/sykus'

directory theme_path do
  action :create
  mode 0755
  recursive true
end

cookbook_file "#{theme_path}/index.theme" do
  action :create
  mode 0644
  source 'index.theme'
end

template "#{theme_path}/index.html" do
  action :create
  mode 0644
  source 'index.html.erb'
  variables domain: data_bag_item('client', 'client')['server_domain']
end

