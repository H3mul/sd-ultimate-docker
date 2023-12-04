#!/usr/bin/env bash
echo "Starting VS Server..."
PASSWORD=${VS_SERVER_PASSWORD} \
nohup code-server \
    --verbose \
    --bind-addr 0.0.0.0:8080 \
    > /workspace/logs/vs-server.log 2>&1 &           
echo $! > /vs-server.pid
echo "Started VS Server"
echo "Log file: /workspace/logs/vs-server.log"
echo "Pid file: /vs-server.pid"