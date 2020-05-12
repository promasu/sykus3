#!/bin/busybox sh

echo -n "Melde erfolgreiche Installation..."

MAC="$(cat /tmp/net.mac)"
RES="$(sni_api "confirm?mac=$MAC&cpu_speed=$CPU_SPEED&ram_mb=$RAM_MB")"

[ "$RES" == "ok" ] || sni_error "confirm failed"

echo "ok"

