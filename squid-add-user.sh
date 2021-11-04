#!/bin/bash
if [ `whoami` != root ]; then
	echo "ERROR: You need to run the script as user root or add sudo before command."
	exit 1
fi

if [ ! -f /usr/bin/htpasswd ]; then
    echo "htpasswd not found"
    exit 1
fi

read -e -p "Enter Proxy username: " proxy_username
read -e -p "Enter Proxy password: " proxy_password
read -e -p "IP from (e.g. 192.168.1.1):" proxy_ip_from
read -e -p "IP to (e.g. 192.168.1.10):" proxy_ip_to


prips $proxy_ip_from $proxy_ip_to | awk -v u="$proxy_username" '{ print $0, u }' >> /etc/squid/users.conf

/usr/bin/htpasswd -b /etc/squid/passwd $proxy_username $proxy_password
/sbin/ip -4 -o addr show scope global | awk '{gsub(/\/.*/,"",$4); print $4":3128"}' | awk -v var="$proxy_username" -v pass="$proxy_password" '{ print $0":"var":"pass }'
systemctl reload squid

#https://stackoverflow.com/questions/55555482/squid-bind-each-outgoing-ip-to-a-user