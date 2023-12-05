#!/usr/bin/env bash
echo "Starting Stable Diffusion Web UI"
cd /stable-diffusion-webui
source ./venv/bin/activate

nohup ./webui.sh -f >> /workspace/logs/a1111.log 2>&1 &
echo $! > /a1111.pid
echo "Stable Diffusion Web UI started"
echo "Log file: /workspace/logs/a1111.log"
echo "Pid file: /a1111.pid"
