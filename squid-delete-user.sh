#!/bin/bash

if [ `whoami` != root ]; then
	echo "ERROR: You need to run the script as user root or add sudo before command."
	exit 1
fi

echo -e "\033[31m";
echo "Which user do you want to delete?"
read user
sed -i "/${user}:/d" /etc/squid/passwd
echo -e "\033[00m";
echo "Available users:"
ls /etc/squid/passwd