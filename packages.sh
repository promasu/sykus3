#!/bin/bash 

if [ "`whoami`" != "root" ]; then 
  sudo $0
  exit
fi

apt-get -y install software-properties-common
apt-add-repository ppa:brightbox/ruby-ng
apt-get update
apt-get -y install \
  vim git-core \
  build-essential ruby-dev libxml2-dev xvnc4viewer \
  ruby2.0 ruby2.0-dev p7zip-full genisoimage qemu-kvm libvirt-bin ruby-switch

ruby-switch --set ruby2.0

gem install --no-rdoc --no-ri ruby-vnc thor
gem install --no-rdoc --no-ri net-ssh -v 4.2.0
gem install --no-rdoc --no-ri net-sftp -v 2.1.2

echo "If this is the initial KVM install you MUST reboot."

