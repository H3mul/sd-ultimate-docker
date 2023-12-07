#!/bin/bash

set -eu

if [ -f /app/pid/track-training-pids.pid ];then
    echo "Killing running instance of this script..."
    rkill $(cat /app/pid/track-training-pids.pid) || true
fi

echo $$ > /app/pid/track-training-pids.pid

# This script runs in the background and tracks common long-running tasks
# which we might want to quit and/or notify the completion of.

mkdir -p /app/pid/training-pids

echo "Clearing past tracked PIDs..."
rm /app/pid/training-pids/*

echo "Listening for training PIDs..."
while true; do
    # 1. locate new processes that match supported tasks (eg, kohya training scripts)
    ps aux | grep "${TRAINING_PID_PATTERN}" | grep -v grep | while read -r line; do
        # 2. extract PID and key info (eg model name)
        pid=$(echo ${line} | awk '{print $2}')
        model_name=$(echo ${line} | grep -Po "output_name=\K\S+" | sed "s/[\"'\`]//g" | sed "s/\s+/_/") # dedupe by kohya output names
        [ -z "${model_name}" ] && continue

        # 3. Add a file to /app/pid with PID and info string
        pid_file="/app/pid/training-pids/${model_name}.pid"
        if [ ! -f ${pid_file} ]; then
            echo "Found a new model being trained: ${model_name}, tracking..."
            echo "${pid}" > ${pid_file}
        fi
    done

    # 4. Check all currently tracked pids to see if any exited, if so quit and/or notify
    for pid_file in /app/pid/training-pids/*.pid; do
        model_name=$(basename ${pid_file} .pid)
        pid=$(cat ${pid_file})

        if ! ps -p ${pid} > /dev/null; then
            echo "Model ${model_name} finished training (PID no longer running)."
            rm ${pid_file}
            [ "${NOTIFY_ON_TRAINING_END}" = true ] && send-notification.sh "Model ${model_name} finished training."
            [ "${SHUTDOWN_AFTER_TRAINING}" = true ] && runpodctl remove pod ${RUNPOD_POD_ID}
        fi
    done
    sleep 30
done
