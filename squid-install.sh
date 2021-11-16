#!/bin/bash

############################################################
# Squid Proxy Installer
############################################################

if [ `whoami` != root ]; then
	echo "ERROR: You need to run the script as user root or add sudo before command."
	exit 1
fi

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

# add ip range to netplan
./squid-add-iprange.sh


if cat /etc/os-release | grep PRETTY_NAME | grep "Ubuntu 20.04"; then
    apt update
    apt -y install prips apache2-utils squid
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
