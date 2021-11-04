#!/bin/bash
############################################################
# Squid Proxy Installer
# Author: Yujin Boby
# Email: admin@serverOk.in
# Github: https://github.com/serverok/squid-proxy-installer/
# Web: https://serverok.in/squid
############################################################

if [ `whoami` != root ]; then
	echo "ERROR: You need to run the script as user root or add sudo before command."
	exit 1
fi

apt install prips

echo "Enter ip range including netmask e.g. (192.168.1.1/28)"
read ip
ips=$(prips $ip | sed -e '1d; $d' | awk -vORS=, '{ print $1 }' | sed 's/,$/\n/')
gsed -i "s/addresses: \[\(.*\)\]/addresses: [$ips]/g" 60-static.yaml

#generate ip list
if [[ -d /etc/netplan/ ]]; then
    cp -i 60-static.yaml /etc/netplan/60-static.yaml
else
   echo "Netplan not installed"
   exit 1
fi


# if [ `whoami` != root ]; then
# 	echo "ERROR: You need to run the script as user root or add sudo before command."
# 	exit 1
# fi

# if [[ -d /etc/squid/ ]]; then
#     echo "Squid Proxy already installed. Uninstalling .... :)"
#     sh squid-uninstall.sh
#     exit 1
# fi


if cat /etc/os-release | grep PRETTY_NAME | grep "Ubuntu 20.04"; then
    apt update
    apt -y install apache2-utils squid
    touch /etc/squid/passwd
    rm -f /etc/squid/squid.conf
    touch /etc/squid/blacklist.acl
    cp -i squid.conf /etc/squid/squid.conf
    if [ -f /sbin/iptables ]; then
        /sbin/iptables -I INPUT -p tcp --dport 3128 -j ACCEPT
        /sbin/iptables-save
    fi
    service squid restart
    systemctl enable squid
    ./squid-conf-ip.sh
fi


# if cat /etc/os-release | grep PRETTY_NAME | grep "Ubuntu 20.04"; then
#     /usr/bin/apt update
#     /usr/bin/apt -y install apache2-utils squid3
#     touch /etc/squid/passwd
#     /bin/rm -f /etc/squid/squid.conf
#     /usr/bin/touch /etc/squid/blacklist.acl
#     /usr/bin/wget --no-check-certificate -O /etc/squid/squid.conf https://raw.githubusercontent.com/serverok/squid-proxy-installer/master/squid.conf
#     if [ -f /sbin/iptables ]; then
#         /sbin/iptables -I INPUT -p tcp --dport 3128 -j ACCEPT
#         /sbin/iptables-save
#     fi
#     service squid restart
#     systemctl enable squid


# echo
# echo "To create a proxy user, run command: squid-add-user"
# echo 
