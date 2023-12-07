#!/usr/bin/env bash
set -eu

echo "Starting Stable Diffusion Web UI"
cd ${A1111_ROOT}
source ./venv/bin/activate

export LD_PRELOAD=${A1111_ROOT}/venv/lib/python3.10/site-packages/nvidia/cuda_runtime/lib/libcudart.so.12

nohup ./webui.sh -f >> /workspace/logs/a1111.log 2>&1 &
echo $! > /app/pid/a1111.pid
echo "Stable Diffusion Web UI started"
echo "Log file: /workspace/logs/a1111.log"
echo "Pid file: /app/pid/a1111.pid"
