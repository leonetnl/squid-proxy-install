#!/bin/bash

read -e -p "Enter Discord Token: " api_key_value

key="DISCORD_TOKEN"
path="./.env"

echo "$key=$api_key_value" > $path
echo "Discord token set"