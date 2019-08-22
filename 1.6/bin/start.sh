#!/bin/bash

# Make sure conf folder is available
if [ ! -d $RSERVER_HOME/conf ]
	then
	mkdir -p $RSERVER_HOME/conf
	cp -r /usr/share/rserver/conf/* $RSERVER_HOME/conf
fi

# Start rserver
/usr/share/rserver/bin/rserver
