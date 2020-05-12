file '/etc/timezone' do
  action :create
  mode 0644
  content 'Europe/Berlin'
end

