#!/bin/busybox sh

echo -n "Konfiguriere Rechner..."

mount /dev/sda1 /mnt 2>/dev/null || sni_error "mount failed"

cat /tmp/net.hostname > /mnt/etc/hostname

# make sure eth0 stays always the same (used as bonding ethernet address)
UDEV_FILE=/mnt/etc/udev/rules.d/42-sykus-net.rules
MAC="$(cat /tmp/net.mac |tr '[A-Z]' '[a-z]')"

echo -n 'SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ' > $UDEV_FILE
echo "ATTR{address}==\"$MAC\", NAME=\"eth0\"" >> $UDEV_FILE

umount /mnt
sync

echo "ok"

