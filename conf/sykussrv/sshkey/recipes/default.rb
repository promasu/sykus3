directory '/root/.ssh/' do
  action :create
  mode 0700
end

file '/root/.ssh/authorized_keys' do
  action :create
  mode 0600
  content data_bag_item('server', 'server')['ssh_pubkey']
end

