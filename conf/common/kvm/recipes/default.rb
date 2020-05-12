%w{qemu-kvm libvirt-bin lzma zerofree}.each do |name|
  package name do
    action :install
  end
end

bash 'reload kvm modules to fire udev and modprobe.d hooks' do
  only_if { `which qemu-x86_64`.strip == '' } 
  code <<-EOF
    rmmod kvm_intel
    rmmod kvm_amd
    rmmod kvm
    modprobe kvm
    modprobe kvm_amd
    modprobe kvm_intel
    exit 0
  EOF
end

