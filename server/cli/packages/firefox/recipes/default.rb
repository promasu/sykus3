template '/etc/firefox/syspref.js' do
  action :create
  mode 0644
  variables domain: data_bag_item('client', 'client')['server_domain']
  source 'syspref.js.erb'
end


