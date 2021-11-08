#!/bin/bash

pip install python-dotenv
ps ax | grep squid-bot.py | awk '{ print $1 }' | xargs kill -9
nohup python3 ./squid-bot.py &