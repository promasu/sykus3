cookbook_file '/etc/default/grub' do
  action :create
  mode 0644
  source 'grub'
  notifies :run, 'execute[update-grub]', :immediately
end

execute 'update-grub' do
  action :nothing
end

