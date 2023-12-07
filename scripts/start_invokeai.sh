#!/usr/bin/env bash
echo "Starting InvokeAI..."
source ${INVOKEAI_ROOT}/venv/bin/activate

nohup ${INVOKEAI_ROOT}/scripts/invokeai-web.py \
    >> /workspace/logs/invokeai.log 2>&1 &           
echo $! > /app/pid/invokeai.pid
echo "Started InvokeAI"
echo "Log file: /workspace/logs/invokeai.log"
echo "Pid file: /app/pid/invokeai.pid"