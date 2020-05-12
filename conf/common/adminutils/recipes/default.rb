%w{
  vim nmap iptraf iotop htop molly-guard ethtool
}.each do |name|
  package name do 
    action :install
  end
end

cookbook_file '/etc/default/locale' do
  action :create
  mode 0644
  source 'locale'
end

