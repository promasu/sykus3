#!/bin/bash -e

# REVIEW ipv6 support

# cleanup
iptables  -t nat    -F
iptables  -t mangle -F
iptables  -t filter -F
ip6tables -t mangle -F
ip6tables -t filter -F

# default policy, drop everything
iptables  -P FORWARD DROP
iptables  -P INPUT   DROP
iptables  -P OUTPUT  DROP
ip6tables -P FORWARD DROP
ip6tables -P INPUT   DROP
ip6tables -P OUTPUT  DROP

# allow loopback ipv6 (not doing so breaks some services)
ip6tables -A INPUT -i lo -j ACCEPT
ip6tables -A OUTPUT -o lo -j ACCEPT
 
# always accept established connections
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT   -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT  -m state --state ESTABLISHED,RELATED -j ACCEPT

# allow incoming icmp
# put this before invalid packets to allow broadcast replies to get through
iptables -A INPUT -p icmp -m icmp --icmp-type any -j ACCEPT

# drop packets with invalid state
iptables -A FORWARD -m state --state INVALID -j DROP
iptables -A INPUT   -m state --state INVALID -j DROP
iptables -A OUTPUT  -m state --state INVALID -j DROP

# drop spoofed packets
iptables -A INPUT -i ethwan -s 192.168.122.0/24 -j DROP
iptables -A INPUT -i ethwan -s 10.41.0.0/16 -j DROP
iptables -A INPUT -i ethwan -s 10.42.0.0/16 -j DROP
iptables -A INPUT -i ethwan -s 127.0.0.0/8  -j DROP

# redirect all local direct http traffic to web server to show proxy info page
iptables -t nat -A PREROUTING -i ethlan ! -d 10.42.1.1 -p tcp -m tcp \
  --dport 80 -j REDIRECT --to-ports 82

# allow all access from virtual networks + NAT
iptables -t nat -A POSTROUTING -s 10.41.0.0/16 ! -d 10.41.0.0/16 -j MASQUERADE
iptables -A INPUT -i virsykuscli -p tcp -m tcp -m multiport \
  --dports 53 -j ACCEPT
iptables -A INPUT -i virsykuscli -p udp -m udp -m multiport \
  --dports 53,67,68 -j ACCEPT
iptables -A FORWARD -s 10.41.0.0/16 -i virsykuscli -j ACCEPT
iptables -A FORWARD -i virsykuscli -o virsykuscli -j ACCEPT

# allow all access from local host
iptables -A INPUT -i lo        -j ACCEPT
iptables -A INPUT -s 10.42.1.1 -j ACCEPT
iptables -A OUTPUT             -j ACCEPT

# allow http, https and ssh access from everywhere
iptables -A INPUT -p tcp -m tcp -m multiport --dports 22,80,443 -j ACCEPT

# allow lan services
iptables -A INPUT -i ethlan -p tcp -m tcp -m multiport \
  --dports 53,81,82,83,445,631,3128 -j ACCEPT
iptables -A INPUT -i ethlan -p udp -m udp -m multiport \
  --dports 53,67,68,69,123,1812 -j ACCEPT

# enable packet forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

