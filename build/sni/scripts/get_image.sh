#!/bin/sh

echo "Installiere neues System..."
wget "http://10.42.1.1:81/release.img" -O - |unlzma -c > /dev/sda1 \
  || sni_error "download wget failed"
echo "OK."

