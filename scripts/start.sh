#!/usr/bin/env bash
set -e  # Exit the script if any statement returns a non-true return value

# ---------------------------------------------------------------------------- #
#                          Function Definitions                                #
# ---------------------------------------------------------------------------- #

# Execute script if exists
execute_script() {
    local script_path=$1
    local script_msg=$2
    if [[ -f ${script_path} ]]; then
        echo "${script_msg}"
        bash ${script_path}
    fi
}

# Setup ssh
setup_ssh() {
    if [[ $PUBLIC_KEY ]]; then
        echo "Setting up SSH..."
        mkdir -p ~/.ssh
        echo -e "${PUBLIC_KEY}\n" >> ~/.ssh/authorized_keys
        chmod 700 -R ~/.ssh

        if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
            ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -q -N ''
        fi

        if [ ! -f /etc/ssh/ssh_host_dsa_key ]; then
            ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -q -N ''
        fi

        if [ ! -f /etc/ssh/ssh_host_ecdsa_key ]; then
            ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -q -N ''
        fi

        if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
            ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -q -N ''
        fi

        service ssh start

        echo "SSH host keys:"
        cat /etc/ssh/*.pub
    fi
}

# Export env vars
export_env_vars() {
    echo "Exporting environment variables..."
    printenv | grep -E '^RUNPOD_|^PATH=|^_=' | awk -F = '{ print "export " $1 "=\"" $2 "\"" }' >> /etc/rp_environment
    echo 'source /etc/rp_environment' >> ~/.bashrc
}

# Start jupyter lab
start_jupyter() {
    if [[ $JUPYTER_PASSWORD ]]; then
        echo "Starting Jupyter Lab..."
        mkdir -p /workspace && \
        cd / && \
        nohup jupyter lab --allow-root \
          --no-browser \
          --port=8888 \
          --ip=* \
          --FileContentsManager.delete_to_trash=False \
          --ContentsManager.allow_hidden=True \
          --ServerApp.terminado_settings='{"shell_command":["/bin/bash"]}' \
          --ServerApp.token=${JUPYTER_PASSWORD} \
          --ServerApp.allow_origin=* \
          --ServerApp.preferred_dir=/workspace &> /workspace/logs/jupyter.log &
        echo "Jupyter Lab started"
    fi
}

start_vsserver () {
    mkdir -p /workspace/vs-server
    [ ! -f /workspace/vs-server/settings.json ] && \
        cp /vs-server/settings.json /workspace/vs-server/settings.json
    mkdir -p /root/.local/share/code-server/User
    rm -rf /root/.local/share/code-server/User/settings.json
    ln -s /workspace/vs-server/settings.json /root/.local/share/code-server/User/settings.json
    if [[ $VS_SERVER_PASSWORD ]]; then
        /start_vs_server.sh
    fi
}

# ---------------------------------------------------------------------------- #
#                               Main Program                                   #
# ---------------------------------------------------------------------------- #

execute_script "/pre_start.sh" "Running pre-start script..."

echo "Pod Started"

setup_ssh
# start_jupyter
start_vsserver
export_env_vars

execute_script "/post_start.sh" "Running post-start script..."

echo "Container is READY!"

tail -F /workspace/logs/*
