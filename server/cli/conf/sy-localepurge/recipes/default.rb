package 'localepurge' do
  action :install
end

cookbook_file '/etc/locale.nopurge' do
  source 'locale.nopurge'
  mode 0600
end

execute 'localepurge'

