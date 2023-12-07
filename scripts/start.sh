#!/usr/bin/env bash
set -e  # Exit the script if any statement returns a non-true return value

# ---------------------------------------------------------------------------- #
#                          Function Definitions                                #
# ---------------------------------------------------------------------------- #

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
    printenv | grep -E '^RUNPOD_|^PATH=|^_=' | awk -F = '{ print "export " $1 "=\"" $2 "\"" }' >> /etc/environment
    echo 'source /etc/environment' >> ~/.bashrc
}

start_vsserver () {
    mkdir -p /workspace/vs-server
    [ ! -f /workspace/vs-server/settings.json ] && \
        cp /vs-server/settings.json /workspace/vs-server/settings.json
    mkdir -p /root/.local/share/code-server/User
    rm -rf /root/.local/share/code-server/User/settings.json
    ln -s /workspace/vs-server/settings.json /root/.local/share/code-server/User/settings.json
    if [[ $VS_SERVER_PASSWORD ]]; then
        start_vs_server.sh
    fi
}

# ---------------------------------------------------------------------------- #
#                               Main Program                                   #
# ---------------------------------------------------------------------------- #

export_env_vars
setup_ssh

echo "Running pre-start script..."
pre_start.sh | tee /workspace/logs/pre_start.log

if [ "${SHUTDOWN_AFTER_PROVISION}" = true ]; then
    echo "Provisioning complete, shutting down..."
    [ -z ${RUNPOD_POD_ID} ] || runpodctl remove pod ${RUNPOD_POD_ID}
    exit
fi 

echo "Pod Started"

echo "Starting services..."
if [ "${DISABLE_AUTOLAUNCH}" != true ]; then
    # start_a1111.sh A1111 immediately loads the model, so only start manually when necessary
    start_kohya.sh
    start_invokeai.sh
fi

start_vsserver

echo "Container is READY!"

tail -F /workspace/logs/*
