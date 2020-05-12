package 'lilo' do
  action :install
end

cookbook_file '/etc/lilo.conf' do
  source 'lilo.conf'
  mode 0600
end

# remove grub
%w{grub grub-common grub2 grub2-common grub-pc grub-pc-bin}.each do |name|
  package name do
    action :purge
  end
end

directory '/boot/grub' do
  action :delete
  recursive true
end

