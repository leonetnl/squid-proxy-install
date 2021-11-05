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

# loop trough queue
queueids=$(atq | cut -d$'\t' -f1)
arr=($queueids)
for id in ${arr[@]}; do
	qu=$(at -c $id | grep "squid-delete-user.sh" | awk '{print $2}')
	
	if [[ "$qu" == "$user" ]]; then
		echo "Removing job $id"
		atrm $id
	fi
done

systemctl reload squid

echo "Available users:"
cat /etc/squid/passwd



