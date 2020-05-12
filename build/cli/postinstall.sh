#!/bin/bash -e

# packages
export DEBIAN_FRONTEND="noninteractive"
apt-get -y update
apt-get -y dist-upgrade
apt-get -y install chef
update-rc.d -f chef-client disable

# pre-build includes base desktop install (for download/install speed reasons)
apt-get -y install --no-install-recommends xubuntu-desktop

# disable cron / anacron (not needed for imaged clients, may break apt/dpkg)
apt-get -y purge cron anacron 

# cleanup apt
apt-get -y autoremove
apt-get -y clean

# cleanup
rm /var/lib/dhcp/*
rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

poweroff

