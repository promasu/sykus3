#!/bin/sh
cp /cdrom/sykus/net_issue.sh /target/etc
cp /cdrom/sykus/net_issue_cron /target/etc/cron.d
chmod +x /target/etc/net_issue.sh
echo "/etc/net_issue.sh" > /target/etc/rc.local

mkdir -p /target/root/.ssh
cp /cdrom/sykus/insecure_deploy_key.pub /target/root/.ssh/authorized_keys
chmod 600 -R /target/root/.ssh
echo 'PasswordAuthentication no' >> /target/etc/ssh/sshd_config

rm -f /target/etc/udev/rules.d/70-persistent-net.rules
touch /target/etc/udev/rules.d/75-persistent-net-generator.rules

DST="/target/etc/udev/rules.d/42-sykus-net.rules"
rename_if() {
  MAC=`cat /sys/class/net/$1/address`
  echo -n 'SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ' >> $DST
  echo -n 'ATTR{address}=="' >> $DST
  echo -n "$MAC" >> $DST
  echo -n '", NAME="' >> $DST
  echo -n "$2" >> $DST
  echo '"' >> $DST
}

# prevent errors in a one-NIC environment (for buildsrv or testing)
if [ -e /sys/class/net/eth1 ]; then
  rename_if eth0 ethwan
  rename_if eth1 ethlan

  sed -i 's/eth0/ethwan/g' /target/etc/network/interfaces
  echo >> /target/etc/network/interfaces
  cat /cdrom/sykus/interfaces >> /target/etc/network/interfaces
fi

chroot /target apt-add-repository -y ppa:brightbox/ruby-ng
chroot /target apt update
chroot /target apt install ruby2.0 ruby2.0-dev build-essential ruby-switch
chroot /target ruby-switch --set ruby2.0

exit 0

