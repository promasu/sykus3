#!/bin/bash -e

WORK_DIR="/var/lib/sykus3/clibuild"
SPACEFACTOR=1400  # 1024 would be exact fit

cd "$WORK_DIR"

# prepare
bash "$(dirname $0)/cleanup.sh" || true
modprobe nbd max_part=16
mkdir mnt.src mnt.dst

# mount image
qemu-nbd -c /dev/nbd0 sykuscli.qed
partprobe /dev/nbd0
mount /dev/nbd0p1 mnt.src

# get partition size
SIZE="$(df mnt.src |tail -n1 |awk '{print $3}')"
expr $SIZE \* $SPACEFACTOR > release.img.size

# create new filesystem
dd if=/dev/zero of=fs.tmp bs=$SPACEFACTOR count=$SIZE
# large inode count (we ran out once - it wasn't pretty)
mkfs.ext4 -i 4096 -F -O extent fs.tmp  
losetup /dev/loop0 fs.tmp
mount /dev/loop0 mnt.dst

# copy data
cp -a mnt.src/* mnt.dst

# cleanup
bash "$(dirname $0)/cleanup.sh"

# compress
zerofree fs.tmp
lzma -z -c -2 < fs.tmp > release.img

# cleanup
rm fs.tmp sykuscli.qed

