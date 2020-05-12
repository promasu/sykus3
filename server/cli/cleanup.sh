#!/bin/bash -e

WORK_DIR="/var/lib/sykus3/clibuild"
cd "$WORK_DIR"

sync
umount /dev/loop0 || true
umount /dev/nbd0p1 || true
losetup -d /dev/loop0 || true
qemu-nbd -d /dev/nbd0 || true
sleep 1
rmmod nbd || true
rmdir mnt.src mnt.dst

