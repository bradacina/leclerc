import asyncdispatch
import httpclient
import times
import logging
import strutils
import sequtils
import telegram
import leclerc
import server

proc logAvailability(availability: seq[string]) =
    var f: File
    try:
        let f = open("availability.log", fmAppend)
        for a in availability.items:
            f.write($now() & ", " & a & '\n')
    except:
        warn(getCurrentExceptionMsg())
    finally:
        f.close()

proc logResponse(response: string) =
    var f: File
    try:
        f = open("last-response.html", fmWrite)
        f.write(response)
    except:
        warn(getCurrentExceptionMsg())
    finally:
        f.close()

proc checkAvailability() =
    var alreadySeen: seq[string] = @[]
    let bot = newTelegramBot()
    var disconnected = false

    let logger = newFileLogger("bot.log", fmtStr = "[$datetime] [$levelname] ")
    addHandler(logger)
    addTimer(30_000, false, proc(_:AsyncFD): bool = logger.file.flushFile)

    discard stderr.reopen("bot.error.log", fmAppend)

    proc checkAvailabilityImpl(_: AsyncFD): bool {. gcsafe .} =
        let page = getPage()
        let body = page.body
        
        logResponse(body)

        if page.code.is5xx or body.contains("site est indisponible"):
            info("Site is unavailable")
        
        elif not body.contains("radio") and not disconnected:
            let message = "We have been logged out"
            disconnected = true
            discard bot.sendMessage(message)
            warn(message)

        elif body.contains("radio") and disconnected:
            disconnected = false
            let message = "We have reconnected"
            discard bot.sendMessage(message)
            info(message)

        let hours = getHours(body)

        # There is a bug on leclercdrive.fr website where they sometime
        # show all slots as available for a minute or two.
        # In case the number of slots is greater than 1 day's worth (48 slots per day)
        # don't record anything.

        if hours.len > 48:
            discard bot.sendMessage("Large number of availabilities detected")

        if hours.len > 0 and hours.len < 48:
            var newAvailability: seq[string] = @[]
            for h in hours:
                if not alreadySeen.anyIt(it == h):
                    newAvailability.add(h)
                    alreadySeen.add(h)

            if newAvailability.len > 0:
                discard bot.sendMessage("Availability Detected")
                logAvailability(newAvailability)

        if disconnected:
            addTimer(5 * 60_000, true, checkAvailabilityImpl)
        else:
            addTimer(60_000, true, checkAvailabilityImpl)

    discard checkAvailabilityImpl(AsyncFD(0))

when isMainModule:

    startServer(Port(44333))
    checkAvailability()

    runForever()
