%w{build-essential curl software-properties-common}.each do |name|
  package name do
    action :install
  end
end

NODE_APT_TOUCHFILE = '/var/cache/node_apt.touchfile'
unless File.exists? NODE_APT_TOUCHFILE
  execute 'add-apt-repository -y ppa:chris-lea/node.js'
  execute 'apt-get update'
  execute 'apt-get install -y nodejs'
  execute "touch #{NODE_APT_TOUCHFILE}"
end

NODE_TOUCHFILE = '/var/cache/node_update.touchfile'
if (!File.exists?(NODE_TOUCHFILE) || 
    Time.now - File.mtime(NODE_TOUCHFILE) > 36000)

  $NODE_UPDATE = true
  execute "touch #{NODE_TOUCHFILE}"
end

# do not run "npm update -g" as this messes up its own files

