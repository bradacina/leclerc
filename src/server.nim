import asynchttpserver, asyncdispatch, logging, sequtils

const allowedFiles = @["/bot.log", "/bot.error.log", "/monitor.log", "/monitor.error.log", "/availability.log"]

proc updateCookie(reqBody: string) =
    let cookie = reqBody.substr(2)
    let f = open(".cookie", fmWrite)
    f.write(".XPRSDRVAUTH=")
    f.write(cookie)
    f.write(";")
    f.close

proc getFile(file: string): string =
    var f: File
    try:
        f = open(file)
        result = f.readAll
    except:
        warn(getCurrentExceptionMsg())
    finally:
        f.close

proc startServer*(port: Port) =
    var server = newAsyncHttpServer()
    proc cb(req: Request) {.async.} =
        if req.url.path == "/updateCookie" and req.reqMethod == HttpPost:
            updateCookie(req.body)
            await req.respond(Http200, "Cookie updated")
            return
        
        if allowedFiles.any(proc (x:string): bool = x == req.url.path):
            let logContents = getFile(req.url.path[1..^1])
            await req.respond(Http200, logContents)
            return

        if req.url.path == "/leclerc":
            let contents = getFile("index.html")
            await req.respond(Http200, contents)
            return

        await req.respond(Http404, "Not Found")

    discard server.serve(port, cb)