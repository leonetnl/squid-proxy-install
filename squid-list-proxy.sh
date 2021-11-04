#!/bin/bash
cat /etc/squid/passwd | while read line 
do
  userline=(${line//:/ })
  user=${userline[0]}
  pass=${userline[1]}

  /sbin/ip -4 -o addr show scope global | awk '{gsub(/\/.*/,"",$4); print $4":3128"}' | awk -v var="$user" -v pass="$pass" '{ print $0":"var":"pass }'
done