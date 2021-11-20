pip install pyarmor
mkdir ./build/
cd ./build/
ls | grep -v -E 'users.txt|.env' | xargs rm
cd ..
shc -f proxy.sh
mv ./proxy.sh.x ./build/proxy
rm ./proxy.sh.x.c
cp ./netplan.yaml ./build/netplan.yaml
cp ./squid.conf ./build/squid.conf
cp ./squid-bot.py ./build/squid-bot.py
pyarmor obfuscate ./build/squid-bot.py
mv ./build/dist/squid-bot.py ./build/squid-bot.py
mv ./build/dist/pytransform ./build/pytransform
chmod +x ./build/squid-bot.py

# scp root@185.142.27.234:/root/squid-proxy-install/app.zip ./