package 'proxychains' do
  action :install
end

cookbook_file '/etc/proxychains.conf' do
  action :create
  mode 0644
  source 'proxychains.conf'
end

