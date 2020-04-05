# LeclercDrive bot in Nim

LeclercDrive is a chain of online shopping grocery stores in France. It offers pick up time slots where you can drive
in, load up your groceries and be on your way. 

Due to the Corona virus, everyone has started ordering their groceries online which means that the number of
available pick up slots has dried out. New slots are being made available at random times and you need to get fast
on the website to comlete your order before someone else does.

This bot monitors the leclercdrive.fr website and notifies you on a Telegram channel whenever there are newly available
pick up time slots. It's up to you to have your basket pre-filled and your credit card handy!

## Nim version

`1.0.6`

## Build

`nimble -d:ssl build`

## Deployment

Copy the `monitor`, `bot` and `index.html` file to a location on your server. 

## Config

There are two files that are required for the operation of this bot
- `.cookie` contains the `.XPRSDRVAUTH=xXxXxXxX` auth cookie as handed to an authenticated user by the leclercdrive.fr website
- `.telegram_bot` contains your telegram bot key

## Running

On linux I run it as:
```bash
tmux
./monitor &
```

The bot has a very basic web interface at `YOUR_IP:44333/leclerc` that allows you to inspect the logs and set the
auth cookie in case it gets logged out.

The `monitor` executable is there to restart the `bot` executable in case it dies for various reasons.

## Harcoded values

I've hardcoded the following values (that should be actually exposed on the command line but I can't be bothered)
- Http server is listening on port `:44333` (you can find this in `bot.nim`)
- check interval is 60 seconds - or 300 seconds if the bot has been logged out from leclercdrive.fr (found in `bot.nim`)
- url to check for available time slots at a specific store (found in `leclerc.nim`)
- name of log files (found in `bot.nim`)
- name of Telegram channel that messages are sent to (found in `telegram.nim`)