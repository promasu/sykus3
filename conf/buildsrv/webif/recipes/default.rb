[
  { package: 'less', cmd: 'lessc' },
  { package: 'uglify-js', cmd: 'uglifyjs' },
].each do |cur|
  execute "npm install -g #{cur[:package]}" do
    only_if { $NODE_UPDATE || !File.exists?("/usr/bin/#{cur[:cmd]}") }
  end
end

