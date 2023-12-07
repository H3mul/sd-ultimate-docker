#!/bin/bash

set -eu

MESSAGE="${1-}"

if [ -z "${MESSAGE}" ]; then
    echo "No message provided for notification, quitting early..." >&2
    exit 1
fi

if [ -z "${PUSHBULLET_API_TOKEN}" ]; then
    echo "No pushbullet token provided via \$PUSHBULLET_API_TOKEN variable, quitting early..." >&2
    exit 1
fi

curl -u ${PUSHBULLET_API_TOKEN}: \
	-X POST https://api.pushbullet.com/v2/pushes \
	--header 'Content-Type: application/json' \
	--data-binary "{\"type\":\"note\",\"title\":\"sd-ultimate\",\"body\":\"${MESSAGE}\"}"
