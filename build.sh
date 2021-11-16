rm -rf ./build/
mkdir ./build/
shc -f proxy.sh
mv ./proxy.sh.x ./build/proxy
rm ./proxy.sh.x.c
cp ./netplan.yaml ./build/netplan.yaml
cp ./squid.conf ./build/squid.conf
cp ./squid-bot.py ./build/squid-bot.py


# scp root@185.142.27.234:/root/squid-proxy-install/app.zip ./