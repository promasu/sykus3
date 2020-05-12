package 'debconf-utils' do
  action :install
end

# preseed this because eula-screen defaults to "no"
execute 'echo "ttf-mscorefonts-installer ' +
  'msttcorefonts/accepted-mscorefonts-eula boolean true" ' + 
  '|debconf-set-selections'

package 'ttf-mscorefonts-installer' do
  action :install
end

