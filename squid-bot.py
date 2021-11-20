#!/usr/bin/env python3
import discord
import os
import io
import datetime
from discord.ext import commands
from dotenv import load_dotenv
from apscheduler.schedulers.asyncio import AsyncIOScheduler

load_dotenv()

intents = discord.Intents.default()
intents.members = True

bot = commands.Bot(command_prefix='!', intents=intents)
sched = AsyncIOScheduler()

def bash(command):
  output = os.popen(command).read()
  return "Command executed\n" + output

async def getUser(username):
  print(f"Looking for user {username}")
  for guild in bot.guilds:
    user = discord.utils.get(guild.members, name=username)
    if user is not None:
      return user
  return None 

@bot.command()
async def addUser(ctx, username, password, ip_from, ip_to, days):
    user = await getUser(username)
    if user is None:
      await ctx.send(f"User {username} not found")
    else:
      output = bash("./proxy -m addUser {} {} {} {} {}".format(username, password, ip_from, ip_to, days))
      file = io.StringIO(output)
      dm = await user.create_dm()
      await dm.send("Your proxies", file=discord.File(file, "proxies.txt"))
      await dm.send(f"The proxies will expire in {days} days")
      await ctx.send("Proxy list", file=discord.File(file, "proxies.txt"))
      
@bot.command()
async def deleteUser(ctx, username):
    await ctx.send(bash("./proxy -m deleteUser {}".format(username)))

@bot.command()
async def listUsers(ctx):
    await ctx.send(bash("./proxy -m listUsers"))

@sched.scheduled_job('interval', seconds=5)
async def timed_job():
    print('This job is run every 10 seconds.')
    file = ""
    with open('users.txt') as f:
      for line in f:
        items = line.split(";")
        username = items[0].strip()

        # find user
        user = await getUser(username)

        date = datetime.datetime.strptime(items[1].strip(), '%a %b %d %H:%M:%S %Y')
        should_notify = datetime.datetime.now() > date
        
        if user is not None and should_notify:
          dm = await user.create_dm()
          await dm.send(f"Your proxies will expire in 24 hours")
          print(should_notify)
        elif user is not None:
          file = f"{file}{line}"

    # write remaning users back to file
    with open('users.txt', 'w+') as f:
      f.write(file)

          
sched.start()
bot.run(os.getenv('DISCORD_TOKEN'))