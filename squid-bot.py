import discord
import os
from discord.ext import commands

#client = discord.Client()
bot = commands.Bot(command_prefix='!')

def bash(command):
  output = os.popen(command).read()
  return "Command executed\n" + output


@bot.command()
async def addUser(ctx, username, password, ip_from, ip_to, days):
    await ctx.send(bash("./squid-add-user.sh {} {} {} {} {}".format(username, password, ip_from, ip_to, days)))

@commands.command()
async def foo(ctx, arg):
    await ctx.send(arg)


bot.run("OTA0OTg3OTgxNjkyMTc0MzQ3.YYDhvA.041Xkqvz8tWBx50dLY7eikRhGDw")