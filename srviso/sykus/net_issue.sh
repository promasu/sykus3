#!/bin/bash -e

echo -e "Sykus 3 \\\\n \l \n" > /etc/issue

date >> /etc/issue
echo >> /etc/issue

ifconfig -a |egrep '(Link encap|inet addr|MTU)' >> /etc/issue
echo >> /etc/issue

echo -n "Remote IPv4 address: " >> /etc/issue
dig +short myip.opendns.com @208.67.222.222 @208.67.220.220 >> /etc/issue
echo >> /etc/issue

exit 0

