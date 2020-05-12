#!/bin/busybox sh

echo -n "Installiere Bootloader..."
mount /dev/sda1 /mnt || sni_error "mount failed"
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys

cp /bin/busybox /mnt/busybox
chroot /mnt /busybox mdev -s
rm /mnt/busybox

chroot /mnt lilo >/dev/null || sni_error "lilo failed"

umount /mnt/sys
umount /mnt/proc
umount /mnt 
echo "ok"

