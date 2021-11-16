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
    output = bash("./proxy -m addUser {} {} {} {} {}".format(username, password, ip_from, ip_to, days))
    file = io.StringIO(output)
    await ctx.send("Proxy list", file=discord.File(file, "proxies.txt"))

@bot.command()
async def deleteUser(ctx, username):
    await ctx.send(bash("./proxy -m deleteUser {}".format(username)))

@bot.command()
async def listUsers(ctx):
    await ctx.send(bash("./proxy -m listUsers"))


bot.run(os.getenv('DISCORD_TOKEN'))