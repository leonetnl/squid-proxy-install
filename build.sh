rm -rf ./build/
mkdir ./build/
shc -f proxy.sh
mv ./proxy.sh.x ./build/proxy
rm ./proxy.sh.x.c
cp ./netplan.yaml ./build/netplan.yaml
cp ./squid.conf ./build/squid.conf
cp ./squid-bot.py ./build/squid-bot.py
