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

/usr/bin/htpasswd -b /etc/squid/passwd $proxy_username $proxy_password
/sbin/ip -4 -o addr show scope global | awk '{gsub(/\/.*/,"",$4); print $4":3128"}' | awk -v var="$proxy_username" -v pass="$proxy_password" '{ print $0":"var":"pass }'
systemctl reload squid
