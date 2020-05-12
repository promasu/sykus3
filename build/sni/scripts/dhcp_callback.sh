#!/bin/busybox sh

case "$1" in
  deconfig)
    ifconfig $interface 0.0.0.0
    ;;

  bound|renew)
    ifconfig $interface $ip netmask $subnet
    route add default gw $router dev $interface

    echo "$ip" > /tmp/net.ip
    echo "$hostname" > /tmp/net.hostname
    ;;
esac

