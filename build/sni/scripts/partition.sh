#!/bin/busybox sh

echo -n "Partitioniere Festplatte..."
 
cat > /tmp/part.cmd << EOF
# create new partition table
o
# create main partition
n
p
1

+PARTSIZE_MAIN
# create swap partition
n
p
2
# set size to remaining space


# set partition type to swap
t
2
82
# write changes
w
EOF

SIZE_URL="http://10.42.1.1:81/release.img.size"
HDD_SIZE_MIN_EXACT="$(wget -O - $SIZE_URL 2>/dev/null)"
HDD_SIZE_PART="$(expr $HDD_SIZE_MIN_EXACT \/ 1000)K"
HDD_SIZE_MIN="$(expr $HDD_SIZE_MIN_EXACT \/ 100 \* 110)"
[ "$?" -eq 0 ] || sni_error "cannot get image size (image ready?)"

HDD_SIZE="$(fdisk -l /dev/sda |grep Disk |head -n1 |cut -d' ' -f5)"
[ "$?" -eq 0 ] || sni_error "cannot get disk size (disk installed?)"

if [ "$HDD_SIZE" -lt "$HDD_SIZE_MIN" ]; then
  sni_error "Festplatte zu klein."
fi

cat /tmp/part.cmd \
    |grep -v '#' \
      |sed "s/PARTSIZE_MAIN/$HDD_SIZE_PART/g" \
        |fdisk /dev/sda >/dev/null 2>/dev/null
  
[ "$?" -eq 0 ] || sni_error "partitioning failed"

sync
mdev -s

mkswap /dev/sda2 >/dev/null 2>/dev/null || sni_error "creating swap failed"

echo "ok"

