conf_root = '/tmp/conf'

JSON.parse(File.read(conf_root + '/apt.json')).each do |name|
  package name do
    action :install
  end
end


