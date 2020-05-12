# we use cron for dyndns because the last thing we want is invalid dns
# when the sykus-daemon dies

package 'cron' do
  action :install
end

fqdn= data_bag_item('server', 'server')['domain'] + '.'
token = data_bag_item('server', 'server')['dyndns_key']
url = "https://dyndns.regfish.de/?fqdn=#{fqdn}&thisipv4=1&token=#{token}"

template '/etc/cron.d/dyndns' do
  action :create
  mode 0644
  variables url: url 
  source 'dyndns.erb'
end

