#!/bin/sh

MONITORPID=`pidof monitor`
BOTPID=`pidof bot`

echo $MONITORPID
echo $BOTPID

kill -9 $MONITORPID
kill -9 $BOTPID