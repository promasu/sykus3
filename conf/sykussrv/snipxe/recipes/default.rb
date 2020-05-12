%w{tftpd-hpa syslinux}.each do |name|
  package name do
    action :install
  end
end

service 'tftpd-hpa' do
  provider Chef::Provider::Service::Upstart
end

[
  '/var/lib/sykus3/tftp',
  '/var/lib/sykus3/tftp/conf.d',
  '/var/lib/sykus3/image',
].each do |dir| 
  directory dir do
    action :create
    owner 'sykus3'
    group 'sykus3'
    mode 0755
    recursive true
  end
end

file '/etc/dhcp/sykus.dynamic.conf' do
  action :touch
  user 'sykus3'
  group 'sykus3'
  mode 0644
end

cookbook_file '/etc/default/tftpd-hpa' do
  source 'tftpd-hpa'
  mode 0644
  notifies :restart, 'service[tftpd-hpa]', :immediately
end

bash 'extract kernel and ramdisk' do
  cwd '/var/lib/sykus3/tftp'
  code <<-EOF
    tar -xzf /usr/lib/sykus3/dist/sni.tgz
    chmod 444 vmlinuz initrd.img
  EOF
end

%w{sni.conf local.conf}.each do |file|
  cookbook_file "/var/lib/sykus3/tftp/#{file}" do
    action :create
    mode 0444
    source file
  end
end

%w{pxelinux.0 chain.c32}.each do |file|
  src = "/usr/lib/syslinux/#{file}"
  dst = "/var/lib/sykus3/tftp/#{file}"
  execute "cp #{src} #{dst}" do
    not_if { File.exists? dst }
  end
end

