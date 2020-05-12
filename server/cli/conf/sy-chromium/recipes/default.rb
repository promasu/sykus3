package 'chromium-browser' do
  action :install
end

cookbook_file '/etc/chromium-browser/default' do
  action :create
  source 'default'
  mode 0644
end

directory '/usr/lib/chromium-browser/extensions' do
  action :create
  mode 0755
end

[ 
  'cfhdojbkjhnklbpkdaibdccddilifddb', # adblock
  'dpjamkmjmigaoobjbekmfgabipmfilij', # blank new tab
].each do |id|
  cookbook_file "/usr/lib/chromium-browser/extensions/#{id}.json" do
    action :create
  source 'plugin.json'
  mode 0644
  end
end

