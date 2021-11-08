#!/usr/bin/env python3

import discord
import os
import io
from discord.ext import commands
from dotenv import load_dotenv

load_dotenv()

#client = discord.Client()
bot = commands.Bot(command_prefix='!')

def bash(command):
  output = os.popen(command).read()
  return "Command executed\n" + output


@bot.command()
async def addUser(ctx, username, password, ip_from, ip_to, days):
    output = bash("./squid-add-user.sh {} {} {} {} {}".format(username, password, ip_from, ip_to, days))
    file = io.StringIO(output)
    await ctx.send("Proxy list", file=discord.File(file, "proxies.txt"))

@bot.command()
async def deleteUser(ctx, username):
    await ctx.send(bash("./squid-delete-user.sh {}".format(username)))

@bot.command()
async def listUsers(ctx):
    await ctx.send(bash("./squid-list-users.sh"))




#bot.run("OTA0OTg3OTgxNjkyMTc0MzQ3.YYDhvA.041Xkqvz8tWBx50dLY7eikRhGDw")
bot.run(os.getenv('DISCORD_TOKEN'))