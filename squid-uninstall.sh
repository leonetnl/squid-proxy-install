#!/bin/bash


if [ `whoami` != root ]; then
	echo "ERROR: You need to run the script as user root or add sudo before command."
	exit 1
fi

/usr/bin/apt -y remove --purge squid
rm -rf /etc/squid/

echo 
echo 
echo "Squid Proxy uninstalled."
echo 