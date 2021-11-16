#!/bin/bash

base64 -d <<<"CiAgX19fX19fICAgX18gIF9fICAgICAgICAgICAgICAgICAgICAgICAgX18gICAgIAogLyAgICAg
IFwgLyAgfC8gIHwgICAgICAgICAgICAgICAgICAgICAgLyAgfCAgICAKLyQkJCQkJCAgfCQkLyAk
JCB8ICBfX19fX18gICBfX19fX19fICAgXyQkIHxfICAgCiQkIFxfXyQkLyAvICB8JCQgfCAvICAg
ICAgXCAvICAgICAgIFwgLyAkJCAgIHwgIAokJCAgICAgIFwgJCQgfCQkIHwvJCQkJCQkICB8JCQk
JCQkJCAgfCQkJCQkJC8gICAKICQkJCQkJCAgfCQkIHwkJCB8JCQgICAgJCQgfCQkIHwgICQkIHwg
ICQkIHwgX18gCi8gIFxfXyQkIHwkJCB8JCQgfCQkJCQkJCQkLyAkJCB8ICAkJCB8ICAkJCB8LyAg
fAokJCAgICAkJC8gJCQgfCQkIHwkJCAgICAgICB8JCQgfCAgJCQgfCAgJCQgICQkLyAKICQkJCQk
JC8gICQkLyAkJC8gICQkJCQkJCQvICQkLyAgICQkLyAgICAkJCQkLyAg"
echo
echo
echo "Proxy script"
echo
echo
# require root before execution
if [ `whoami` != root ]; then
	echo "ERROR: You need to run the script as user root or add sudo before command."
	exit 1
fi

# OS check
if cat /etc/os-release | grep PRETTY_NAME | grep -q -v "Ubuntu 20.04"; then
    echo "Script only supports Ubuntu 20.04"
	exit 1
fi

# IP check
serverIP=$(dig +short myip.opendns.com @resolver1.opendns.com)
ips="185.142.27.180, 185.142.27.32, 185.142.27.234, 154.16.202.117"


if echo $ips | grep -q -v $serverIP; then 
    echo "Script not running on this server"
	exit 1
fi

running_file_name=$(basename "$0")
args=("$@")

# read options / methods
while getopts m: flag
do
    case "${flag}" in
        m) method=${OPTARG};;
    esac
done


#########################################################################################################
#########################################################################################################
############################################# CONFIG IPS ################################################
#########################################################################################################
#########################################################################################################

configIps() {
    IP_ALL=$(/sbin/ip -4 -o addr show scope global | awk '{gsub(/\/.*/,"",$4); print $4}')

    IP_ALL_ARRAY=($IP_ALL)

    SQUID_CONFIG="\n"

    for IP_ADDR in ${IP_ALL_ARRAY[@]}; do
        ACL_NAME="proxy_ip_${IP_ADDR//\./_}"
        SQUID_CONFIG+="acl ${ACL_NAME}  myip ${IP_ADDR}\n"
        SQUID_CONFIG+="tcp_outgoing_address ${IP_ADDR} ${ACL_NAME}\n\n"
    done

    echo "Updating squid config"

    echo -e $SQUID_CONFIG > /etc/squid/outgoing.conf

    echo "Restarting squid..."

    systemctl restart squid

    echo "Done"

}

#########################################################################################################
#########################################################################################################
################################################ ADD IPS ################################################
#########################################################################################################
#########################################################################################################

addIps() {
    echo -e "\e[92mEnter ip range including netmask e.g. (192.168.1.1/28)"
    echo -e "\033[00m";
    read ip
    ips=$(prips $ip | sed -e '1d; $d' | awk -vORS=, '{ print $1 "/32" }' | sed 's/,$/\n/')
    sed -i "s~addresses: \[\(.*\)\]~addresses: [$ips]~g" netplan.yaml

    #generate ip list
    if [[ -d /etc/netplan/ ]]; then
        cp -i netplan.yaml /etc/netplan/60-static.yaml
        netplan apply
    else
    echo "Netplan not installed"
    exit 1
    fi
}

#########################################################################################################
#########################################################################################################
############################################## SQUID STATUS #############################################
#########################################################################################################
#########################################################################################################

status() {
    systemctl status squid
}

#########################################################################################################
#########################################################################################################
############################################## SQUID START #############################################
#########################################################################################################
#########################################################################################################

start() {
    systemctl start squid
}

#########################################################################################################
#########################################################################################################
############################################ SQUID RESTART ##############################################
#########################################################################################################
#########################################################################################################

restart() {
    systemctl restart squid
}

#########################################################################################################
#########################################################################################################
############################################## SQUID STOP## #############################################
#########################################################################################################
#########################################################################################################

stop() {
    systemctl stop squid
}

#########################################################################################################
#########################################################################################################
########################################### UNINSTALL SQUID #############################################
#########################################################################################################
#########################################################################################################

uninstallSquid() {
    /usr/bin/apt -y remove --purge squid
    rm -rf /etc/squid/

    echo 
    echo 
    echo "Squid Proxy uninstalled."
    echo 
}

#########################################################################################################
#########################################################################################################
############################################# INSTALL SQUID #############################################
#########################################################################################################
#########################################################################################################

installSquid() {
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
        uninstallSquid
    fi
    echo
    echo -e "\033[00m";

    # add ip range to netplan
    addIps

    if cat /etc/os-release | grep PRETTY_NAME | grep "Ubuntu 20.04"; then
        apt update
        apt -y install python3-pip prips apache2-utils squid
        pip install -U discord.py
        pip install python-dotenv
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
        configIps
        
    fi
}


#########################################################################################################
#########################################################################################################
################################################ ADD USER ###############################################
#########################################################################################################
#########################################################################################################

addUser() {

    if  test -n "${args[2]}" && 
        test -n "${args[3]}" &&
        test -n "${args[4]}" && 
        test -n "${args[5]}" &&
        test -n "${args[6]}"; then
        proxy_username=${args[2]}
        proxy_password=${args[3]}
        proxy_ip_from=${args[4]}
        proxy_ip_to=${args[5]}
        expire_days=${args[6]}
    else
        read -e -p "Enter Proxy username: " proxy_username
        read -e -p "Enter Proxy password: " proxy_password
        read -e -p "IP from (e.g. 192.168.1.1):" proxy_ip_from
        read -e -p "IP to (e.g. 192.168.1.10):" proxy_ip_to
        read -e -p "In how many days will this user expire? 0 for not expiring" expire_days
    fi

    if [ ! -f /usr/bin/htpasswd ]; then
        echo "htpasswd not found"
        exit 1
    fi

    if grep -q "${proxy_username}:" /etc/squid/passwd; then
        echo "Username already exists"
        exit 1
    fi

    IP_ALL=$(/sbin/ip -4 -o addr show scope global | awk '{gsub(/\/.*/,"",$4); print $4}')
    IP_ALL_ARRAY=($IP_ALL)

    if !( ( echo ${IP_ALL_ARRAY[@]} | grep -qw $proxy_ip_from ) && ( echo ${IP_ALL_ARRAY[@]} | grep -qw $proxy_ip_to ) ) ; then
        echo "IP not found on the server"
        echo $IP_ALL | awk '{ print $0 }'
        exit 1
    fi


    if [ $expire_days -gt 0 ]; then
        echo "${PWD}/${running_file_name} -m deleteUser ${proxy_username}" | at "now + ${expire_days} day"
    fi


    ips=$(prips $proxy_ip_from $proxy_ip_to)

    /usr/bin/htpasswd -b /etc/squid/passwd $proxy_username $proxy_password

    iplist=($ips)
    for ip in ${iplist[@]}; do
        echo "${ip} ${proxy_username}" >> /etc/squid/users.conf
        echo "${ip}:3128:${proxy_username}:${proxy_password}"
    done

    systemctl reload squid
}

#########################################################################################################
#########################################################################################################
############################################### DELETE USER #############################################
#########################################################################################################
#########################################################################################################

deleteUser() {
    if test -n "${args[2]}"; then
        user=${args[2]}
    else
        read -e -p "Which user do you want to delete?" user
    fi

    sed -i "/${user}:/d" /etc/squid/passwd
    sed -i "/ ${user}/d" /etc/squid/users.conf

    # loop trough queue
    queueids=$(atq | cut -d$'\t' -f1)
    arr=($queueids)
    for id in ${arr[@]}; do
        qu=$(at -c $id | grep "${running_file_name}" | awk '{print $4}')
        
        if [[ "$qu" == "$user" ]]; then
            atrm $id
        fi
    done

    systemctl reload squid
    echo "User ${user} deleted"
}

#########################################################################################################
#########################################################################################################
################################################ LIST USERS #############################################
#########################################################################################################
#########################################################################################################

listUsers() {
    sed 's/:.*//' /etc/squid/passwd
}

#########################################################################################################
#########################################################################################################
##################################### CONFIGURE DISCORD BOT #############################################
#########################################################################################################
#########################################################################################################

configureBot() {
    read -e -p "Enter Discord Token: " api_key_value
    key="DISCORD_TOKEN"
    path="./.env"

    echo "$key=$api_key_value" > $path
    echo "Discord token set"
}

#########################################################################################################
#########################################################################################################
######################################### START DISCORD BOT #############################################
#########################################################################################################
#########################################################################################################

startBot() {
    ps ax | grep squid-bot.py | awk '{ print $1 }' | xargs kill -9
    echo "Starting bot....."
    sleep 5s
    nohup python3 ./squid-bot.py &
}

#########################################################################################################
#########################################################################################################
######################################## GLOBAL ENTRY POINT #############################################
#########################################################################################################
#########################################################################################################

start() {
    PS3='Please enter your choice: '
    options=("Add user" "Delete user" "List users" "Install Squid" "Uninstall Squid" "Squid status" "Squid restart" "Squid start" "Squid stop" "Start Discord bot" "Set Discord api key" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            ${options[0]})
                addUser
                ;;
            ${options[1]})
                deleteUser
                ;;
            ${options[2]})
                listUsers
                ;;   
            ${options[3]})
                installSquid
                ;;
            ${options[4]})
                uninstallSquid
                ;;
            ${options[5]})
                status
                ;;
            ${options[6]})
                restart
                ;;
            ${options[7]})
                start
                ;;
            ${options[8]})
                stop
                ;;
            ${options[9]})
                startBot
                ;;
            ${options[10]})
                configureBot
                ;;
            ${options[11]})
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
}

#########################################################################################################
#########################################################################################################
################################################ START ##################################################
#########################################################################################################
#########################################################################################################

if [ -z "$method" ]; then
    start
else
    eval $method
fi

