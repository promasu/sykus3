#!/bin/bash -e

# extract currently installed kernel
# `uname -r` gets currently *running* kernel, which might not be 
# in the repository anymore
KERNEL=$(dpkg --print-avail linux-image-generic |grep Depends \
  |ruby -pe "gsub(/(.*?)linux-image-([0-9.-]*generic)(.*)/, '\\2')")

if ! grep -q Ubuntu /etc/os-release; then
  echo "You must be running Ubuntu to build SNI."
  exit 1
fi

# download kernel and modules
rm -rf apt || true
mkdir -p apt
cd apt
aptitude download linux-image-$KERNEL:i386 \
  linux-image-extra-$KERNEL:i386 busybox-static:i386
cd ..

# target directory
rm -rf dist || true
mkdir dist

# temp directory
rm -rf tmp || true
mkdir -p tmp/archive tmp/rd/{bin,etc,lib/modules/$KERNEL}
cd tmp

# extract kernel and modules / busybox
cd archive
ar p ../../apt/linux-image-$KERNEL*.deb data.tar.bz2 |tar xj
ar p ../../apt/busybox*.deb data.tar.gz |tar xz
ar p ../../apt/linux-image-extra-$KERNEL*.deb data.tar.bz2 |tar xj

# copy kernel
cp boot/vmlinuz* ../../dist/vmlinuz

# delete unneeded modules
pushd lib/modules/$KERNEL/kernel/drivers
rm -rf isdn video staging gpu infiniband hwmon 
rm -rf net/{usb,wan,wireless} scsi media
popd

# copy modules from kernel packages
mkdir ../rd/lib/modules/$KERNEL/kernel
cp -R lib/modules/$KERNEL/kernel/drivers ../rd/lib/modules/$KERNEL/kernel
cp lib/modules/$KERNEL/modules.{builtin,order} ../rd/lib/modules/$KERNEL

# copy busybox executable
cp bin/busybox ../rd/bin

cd ../..

# extract keymap (make sure console-data package is installed!)
loadkeys de -b > tmp/rd/etc/german.kmap

# copy scripts
cp -R scripts tmp/rd
cp -R etc/* tmp/rd/etc
ln -s bin/busybox tmp/rd/init

# create initrd
cd tmp/rd
depmod -a -b . $KERNEL
rm -f lib/modules/*/*map
find . -print0 |xargs -0 chmod 700
find . -print0 |cpio -o0 -Hnewc > ../initrd
lzma -6 ../initrd
cp ../initrd.lzma ../../dist/initrd.img
cd ../..

# cleanup
rm -rf tmp apt

echo "Done."

