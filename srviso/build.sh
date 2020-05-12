#!/bin/bash -e

VANILLA_ISO="https://releases.ubuntu.com/14.04/ubuntu-14.04.6-server-amd64.iso"
VANILLA_ISO_MD5="e750536067b6fff7f9934a13466fe2db"

# get vanilla image
cd $(dirname $0)
mkdir -p iso
cd iso

if [ ! -e vanilla.iso ]; then
  wget $VANILLA_ISO -O vanilla.iso
fi

if [ "`md5sum -b vanilla.iso`" != "$VANILLA_ISO_MD5 *vanilla.iso" ]; then
  echo "MD5 mismatch!"
  exit 1
fi
cd ..

# extract
rm -rf tmp || true
7z x iso/vanilla.iso -o./tmp

# modify
cp sykus/menu.cfg tmp/isolinux/isolinux.cfg
cp -R sykus tmp
cp ../keys/insecure_deploy_key.pub tmp/sykus

# re-pack
genisoimage -r -J -l -b isolinux/isolinux.bin \
  -c isolinux/boot.cat \
  -no-emul-boot -boot-load-size 4 -boot-info-table -o srv.iso tmp

# cleanup
rm -rf tmp

