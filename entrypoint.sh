#!/bin/sh -e

if [[ -n "$GID" ]]; then
    groupmod -o -g $GID synapse
fi

if [[ -n "$UID" ]]; then
    usermod -o -u $UID synapse
fi

if [ "$1" = 'generate' ]; then
    exec su-exec synapse python -m synapse.app.homeserver \
        --generate-config \
        --config-path /config/homeserver.yaml \
        --report-stats=yes \
        --server-name "$2"
else
    exec su-exec synapse python -m synapse.app.homeserver \
        --config-path /config/homeserver.yaml
fi
