#!/bin/bash
set -e

if [ "$1" = 'app' ]; then
    chown -R rserver "$RSERVER_HOME"

    exec gosu rserver /opt/obiba/bin/start.sh
fi

exec "$@"
