#!/bin/bash

set -eu

TRACKING_PID=${1-}

if [ -z ${TRACKING_PID} ] && [ ! -z ${POD_TERMINATION_PID_PATTERN} ]; then
    TRACKING_PID=$(pgrep -f ${POD_TERMINATION_PID_PATTERN} | tail -n 1)
    echo "Tracking the first PID of the process matching ${POD_TERMINATION_PID_PATTERN}: ${TRACKING_PID}..."
fi

if [ -z ${TRACKING_PID} ]; then
    echo "No tracking PID found, quitting early..."
    exit 1
fi

ps -opid -p ${TRACKING_PID}
if [ $? -ne 0 ]; then
    echo "pid ${TRACKING_PID} is not active, quitting early..."
fi

if [ -z ${RUNPOD_POD_ID} ]; then
    echo "Not running in a runpod environment, quitting early"
    exit 1
fi

echo "Tracking pid ${TRACKING_PID} and shutting down runpod after it exits..."
nohup sh -c "watch -g -n 30 ps -opid -p ${TRACKING_PID} && runpodctl remove pod ${RUNPOD_POD_ID}" >/dev/null 2>&1 &
