#!/bin/bash
apt install python3-pip
pip install -U discord.py
pip install python-dotenv
ps ax | grep squid-bot.py | awk '{ print $1 }' | xargs kill -9
nohup python3 ./squid-bot.py &