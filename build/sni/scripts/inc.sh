#!/bin/busybox sh

sni_error() {
  echo "fehler"
  echo
  echo "Fehlermeldung:" $1
  echo
  echo Enter zum Neustarten...

  read DUMMY
  reboot
  while true; do
    sleep 1
  done
}

sni_api() {
  wget "http://10.42.1.1:81/api/sni/$1" -O - 2>/dev/null \
    || sni_error "api error" >&2
}

