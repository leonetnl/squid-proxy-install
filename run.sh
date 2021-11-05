#!/bin/bash

PS3='Please enter your choice: '
options=("Add user" "Delete user" "Install Squid" "Uninstall Squid" "Quit")
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
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done