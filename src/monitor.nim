import os, osproc, logging

const MonitoredProc = "bot"

proc monitor(procName:string) =
    var process: Process

    let logger = newFileLogger("monitor.log", fmtStr = "[$datetime] [$levelname] ")
    addHandler(logger)
    discard stderr.reopen("monitor.error.log", fmAppend)

    while true:
        if process.isNil or not process.running:
            info "starting monitored process"
            process = startProcess(procName, options= {poParentStreams})
            logger.file.flushFile
        
        sleep(60_000)


when isMainModule:

    monitor(MonitoredProc)