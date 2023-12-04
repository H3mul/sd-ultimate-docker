echo "Starting Kohya_ss Web UI"
cd ${KOHYA_ROOT}
nohup ./gui.sh --listen 0.0.0.0 --server_port 3010 --headless > /workspace/logs/kohya_ss.log 2>&1 &
echo $! > /kohya_ss.pid
echo "Kohya_ss started"
echo "Log file: /workspace/logs/kohya_ss.log"
echo "Pid file: /kohya_ss.pid"
