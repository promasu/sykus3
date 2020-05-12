#!/bin/busybox sh

TITLE="Sykus 3 - Netzwerk-Systeminstallation"

# create symlinks first
/bin/busybox --install -s /bin

clear
echo -ne "$TITLE\n\n"

. /scripts/inc.sh

mkdir -p /dev /proc /mnt /tmp /sys

echo -n "Erkenne Hardware..."
mount -t proc none /proc || sni_error "proc mount failed"
mount -t sysfs none /sys || sni_error "sysfs mount failed"

load_modules () {
  modprobe -a $(find /sys/devices -name modalias \
    -exec egrep '(pci|usb|input|hid)' {} \;) >/dev/null 2>&1
  mdev -s || sni_error "mdev failed"

  # wait for devices to be detected
  sleep 0.2
}

# run five times to enable all usb devices
load_modules
load_modules
load_modules
load_modules
load_modules

echo "ok"

# watchdog: if SNI is not done after 2 hours, shut down and retry
# must run after /dev has been populated
sleep 7200 && poweroff &

# german keymap
loadkmap < /etc/german.kmap

# no screensaver (there is no setterm)
echo -ne "\033[9;0]\033[14;0]" > /dev/console

echo -n "Konfiguriere Netzwerk..."
[ $(ifconfig -a |grep 'Link encap' |wc -l) -eq 2 ] || sni_error \
  "Mehr als eine Netzwerkkarte. Bitte nur eine Netzwerkkarte pro Rechner."

# export mac address
ifconfig -a |grep HWaddr |awk '{print $5}' > /tmp/net.mac

# allow broadcast pings
echo 0 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

# do dhcp
udhcpc -n eth0 -s /scripts/dhcp_callback.sh >/dev/null || \
  sni_error "DHCP Fehler."
echo "ok"

# initial config done, create a nice screen again
CPU="$(cat /proc/cpuinfo |grep "model name" |cut -d':' -f2 |head -n1)"
HDD_SIZE="$(fdisk -l /dev/sda |grep Disk |head -n1 |cut -d' ' -f5)"
HDD="$(expr $HDD_SIZE \/ 1000 \/ 1000 \/ 1000)"

RAM="$(cat /proc/meminfo |grep MemTotal |awk '{print $2}')"
export RAM_MB="$(expr $RAM \/ 1000)"

BOGOMIPS="$(grep mips /proc/cpuinfo |cut -d':' -f2 |cut -d'.' -f1 |head -n1)"
CORES="$(grep mips /proc/cpuinfo |wc -l)"

# 100% is a 2 GHz Single-Core CPU. This equals 4000 Bogomips.
export CPU_SPEED="$(expr $BOGOMIPS \* $CORES \/ 40)"

clear
echo -ne "$TITLE\n\n"
echo "CPU: [$CPU_SPEED%] $CPU"
echo "RAM: $RAM_MB MB - HDD: $HDD GB"
echo "MAC: $(cat /tmp/net.mac) - IP: $(cat /tmp/net.ip)"
echo "Rechnername: $(cat /tmp/net.hostname)"


if [ "$(cat /tmp/net.hostname)" == "unknownhost" ]; then
  . /scripts/add.sh
else
  echo -e "\n"
  . /scripts/partition.sh
  . /scripts/get_image.sh
  . /scripts/config.sh
  . /scripts/bootloader.sh
  . /scripts/confirm.sh

  echo -e "\n[Enter] startet den Rechner."
  echo "Sonst wird der Rechner in 30 Sekunden ausgeschaltet."

  # wait for enter or 30 seconds to end
  sleep 30 && poweroff &
  read DUMMY  
  reboot
  sleep 3600
fi


