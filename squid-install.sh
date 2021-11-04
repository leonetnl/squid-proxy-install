#!/bin/bash

############################################################
# Squid Proxy Installer
############################################################

if [ `whoami` != root ]; then
	echo "ERROR: You need to run the script as user root or add sudo before command."
	exit 1
fi

chmod +x ./squid-conf-ip.sh
chmod +x ./squid-add-user.sh
chmod +x ./squid-uninstall.sh

echo -e "\033[31m";
read -p "This script will install squid and remove existing installations of squid. Are you sure you want to continue? (y/n)" -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi
echo
echo
if [[ -d /etc/squid/ ]]; then
    echo "Squid Proxy already installed. Uninstalling .... "
    ./squid-uninstall.sh
fi
echo
echo -e "\033[00m";


apt install prips

echo -e "\e[92mEnter ip range including netmask e.g. (192.168.1.1/28)"
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
    
    # add test user
    htpasswd -b /etc/squid/passwd test test
fi
