#!/bin/bash

# Start service
service rserver start

# Wait for the opal server to be up and running
until ls /var/lib/rserver/logs/Rserve.log &> /dev/null
do
	sleep 1
done

# Tail the log
tail -f /var/lib/rserver/logs/Rserve.log

# Stop service
service rserver stop