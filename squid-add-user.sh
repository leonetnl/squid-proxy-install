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

if grep -q "${proxy_username}:" /etc/squid/passwd; then
    echo "Username already exists"
    exit 1
fi

read -e -p "Enter Proxy password: " proxy_password
read -e -p "IP from (e.g. 192.168.1.1):" proxy_ip_from
read -e -p "IP to (e.g. 192.168.1.10):" proxy_ip_to

IP_ALL=$(/sbin/ip -4 -o addr show scope global | awk '{gsub(/\/.*/,"",$4); print $4}')
IP_ALL_ARRAY=($IP_ALL)

if !( ( echo ${IP_ALL_ARRAY[@]} | grep -qw $proxy_ip_from ) && ( echo ${IP_ALL_ARRAY[@]} | grep -qw $proxy_ip_to ) ) ; then
  echo "IP not found on the server"
  echo $IP_ALL | awk '{ print $0 }'
  exit 1
fi

ips=$(prips $proxy_ip_from $proxy_ip_to)

/usr/bin/htpasswd -b /etc/squid/passwd $proxy_username $proxy_password

iplist=($ips)
for ip in ${iplist[@]}; do
    echo "${ip} ${proxy_username}" >> /etc/squid/users.conf
    echo "${ip}:3128:${proxy_username}:${proxy_password}"
done

systemctl reload squid

#https://stackoverflow.com/questions/55555482/squid-bind-each-outgoing-ip-to-a-user