#!/usr/bin/env bash
set -eu

echo "Starting Comfy UI"
cd ${COMFYUI_ROOT}
source ./venv/bin/activate

nohup python ./main.py --listen 0.0.0.0 --port ${COMFYUI_PORT} >> /workspace/logs/comfyui.log 2>&1 &
echo $! > /app/pid/comfyui.pid
echo "Comfy UI started"
echo "Log file: /workspace/logs/comfyui.log"
echo "Pid file: /app/pid/comfyui.pid"
