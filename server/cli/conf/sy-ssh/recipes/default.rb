package 'openssh-server' do
  action :install
end

directory '/root/.ssh' do
  action :create
  mode 0700
end

file '/root/.ssh/authorized_keys' do
  action :create
  mode 0600
  content data_bag_item('client', 'client')['ssh_pubkey']
end

# remove root password
user 'root' do
  action :lock
end

