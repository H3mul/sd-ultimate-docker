#!/usr/bin/env bash
set -eu

echo "Starting VS Server..."
PASSWORD=${VS_SERVER_PASSWORD} \
nohup code-server \
    --bind-addr 0.0.0.0:${VS_CODE_PORT} \
    >> /workspace/logs/vs-server.log 2>&1 &           
echo $! > /app/pid/vs-server.pid
echo "Started VS Server"
echo "Log file: /workspace/logs/vs-server.log"
echo "Pid file: /app/pid/vs-server.pid"