directory '/usr/lib/sykus3/webif' do
  action :create
  owner 'sykus3'
  group 'sykus3'
  mode 0755
end

bash 'extract webif' do
  user 'sykus3'
  group 'sykus3'
  cwd '/usr/lib/sykus3/webif'
  target = data_bag_item('server', 'server')['target']
  verfile = "webif_#{target}.tgz.version"
  code <<-EOF
    rm -rf *
    tar -xzf ../dist/webif_#{target}.tgz
    cp ../dist/#{verfile} .
  EOF

  not_if do 
    Dir.chdir '/usr/lib/sykus3' do
      File.exists?('webif/' + verfile) && 
        File.read('webif/' + verfile) == File.read('dist/' + verfile)
    end
  end
end

