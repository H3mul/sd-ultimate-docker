#!/usr/bin/env bash
echo "Starting Stable Diffusion Web UI"
cd /stable-diffusion-webui
nohup ./webui.sh -f > /workspace/logs/a1111.log 2>&1 &
echo "Stable Diffusion Web UI started"
echo "Log file: /workspace/logs/a1111.log"
