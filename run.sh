#!/bin/bash

PS3='Please enter your choice: '
options=("Add user" "Delete user" "Install Squid" "Uninstall Squid" "Squid status" "Squid restart" "Squid start" "Squid stop" "Quit")
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
            ./squid-install.sh
            ;;
        ${options[3]})
            ./squid-uninstall.sh
            ;;
        ${options[4]})
            systemctl status squid
            ;;
        ${options[5]})
            systemctl restart squid
            ;;
        ${options[6]})
            systemctl start squid
            ;;
        ${options[7]})
            systemctl stop squid
            ;;
        ${options[8]})
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done