#!/bin/bash

read -e -p "Enter Discord API Key: " api_key_value

key="DISCORD_API_KEY"
path="./.env"

echo "$key=$api_key_value" > $path
echo "API-key set"