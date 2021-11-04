apt install prips

echo -e "\e[92mEnter ip range including netmask e.g. (192.168.1.1/28)"
echo -e "\033[00m";
read ip
ips=$(prips $ip | sed -e '1d; $d' | awk -vORS=, '{ print $1 }' | sed 's/,$/\n/')
sed -i "s/addresses: \[\(.*\)\]/addresses: [$ips]/g" 60-static.yaml

#generate ip list
if [[ -d /etc/netplan/ ]]; then
    cp -i 60-static.yaml /etc/netplan/60-static.yaml
    netplan apply
else
   echo "Netplan not installed"
   exit 1
fi