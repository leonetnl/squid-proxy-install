#!/bin/bash

start() {
    PS3='Please enter your choice: '
    options=("Add user" "Delete user" "List users" "Install Squid" "Uninstall Squid" "Squid status" "Squid restart" "Squid start" "Squid stop" "Start Discord bot" "Set Discord api key" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            ${options[0]})
                ./squid-add-user.sh
                ;;
            ${options[1]})
                ./squid-delete-user.sh
                ;;
            ${options[2]})
                ./squid-list-users.sh
                ;;   
            ${options[3]})
                ./squid-install.sh
                ;;
            ${options[4]})
                ./squid-uninstall.sh
                ;;
            ${options[5]})
                systemctl status squid
                ;;
            ${options[6]})
                systemctl restart squid
                ;;
            ${options[7]})
                systemctl start squid
                ;;
            ${options[8]})
                systemctl stop squid
                ;;
            ${options[9]})
                ./squid-bot.sh
                ;;
            ${options[10]})
                ./squid-bot-api.sh
                ;;
            ${options[11]})
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
}

start