# run now so package cache is current before chef gets package version info
execute 'apt-get update' do
  action :nothing
end.run_action :run

execute 'apt-get -y dist-upgrade' do
  environment({ 'DEBIAN_FRONTEND' => 'noninteractive' })
end


