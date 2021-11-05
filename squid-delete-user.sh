#!/bin/bash

if [ `whoami` != root ]; then
	echo "ERROR: You need to run the script as user root or add sudo before command."
	exit 1
fi
                                                                         
if test -n "${1-}"; then
  	user=$1
else
  	read -e -p "Which user do you want to delete?" user
fi

sed -i "/${user}:/d" /etc/squid/passwd
sed -i "/ ${user}/d" /etc/squid/users.conf
echo "Available users:"
cat /etc/squid/passwd