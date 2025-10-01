#!/usr/bin/env bash
set -eu

echo "Starting FluxGym"
cd ${FLUXGYM_ROOT}
source ./venv/bin/activate

GRADIO_SERVER_NAME="0.0.0.0" GRADIO_SERVER_PORT=${FLUXGYM_PORT} nohup python ./app.py >> /workspace/logs/fluxgym.log 2>&1 &
echo $! > /app/pid/fluxgym.pid
echo "FluxGym started"
echo "Log file: /workspace/logs/fluxgym.log"
echo "Pid file: /app/pid/fluxgym.pid"
