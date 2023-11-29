#!/usr/bin/env bash
export PYTHONUNBUFFERED=1

echo "Container is running"

# # Sync venv to workspace to support Network volumes
# echo "Syncing venv to workspace, please wait..."
# rsync -au /venv/ /workspace/venv/
# rm -rf /venv

# # Sync Web UI to workspace to support Network volumes
# echo "Syncing Stable Diffusion Web UI to workspace, please wait..."
# rsync -au /stable-diffusion-webui/ /workspace/stable-diffusion-webui/
# rm -rf /stable-diffusion-webui

# # Sync Kohya_ss to workspace to support Network volumes
# echo "Syncing Kohya_ss to workspace, please wait..."
# rsync -au /kohya_ss/ /workspace/kohya_ss/
# rm -rf /kohya_ss

# # Sync ComfyUI to workspace to support Network volumes
# echo "Syncing ComfyUI to workspace, please wait..."
# rsync -au /ComfyUI/ /workspace/ComfyUI/
# rm -rf /ComfyUI

# # Sync Application Manager to workspace to support Network volumes
# echo "Syncing Application Manager to workspace, please wait..."
# rsync -au /app-manager/ /workspace/app-manager/
# rm -rf /app-manager

# # Fix the venvs to make them work from /workspace
# echo "Fixing Stable Diffusion Web UI venv..."
# /fix_venv.sh /venv /workspace/venv

# echo "Fixing Kohya_ss venv..."
# /fix_venv.sh /kohya_ss/venv /workspace/kohya_ss/venv

# echo "Fixing ComfyUI venv..."
# /fix_venv.sh /ComfyUI/venv /workspace/ComfyUI/venv

# Link models and VAE if they are not already linked

set -x
for model in /models/stable-diffusion/*; do
    model_filename=$(basename "${model}")
    target="/stable-diffusion-webui/models/Stable-diffusion/${model_filename}"
    if [[ ! -L ${target} ]]; then
        ln -s ${model} ${target}
    fi
done

for vae in /models/vae/*; do
    vae_filename=$(basename "${vae}")
    target="/stable-diffusion-webui/models/VAE/${vae_filename}"
    if [[ ! -L ${target} ]]; then
        ln -s ${vae} ${target}
    fi
done
set +x

# Configure accelerate
echo "Configuring accelerate..."
mkdir -p /root/.cache/huggingface/accelerate
mv /accelerate.yaml /root/.cache/huggingface/accelerate/default_config.yaml

# Create logs directory
mkdir -p /workspace/logs

# Start application manager
# cd /workspace/app-manager
# npm start > /workspace/logs/app-manager.log 2>&1 &

# if [[ ${DISABLE_AUTOLAUNCH} ]]
# then
#     echo "Auto launching is disabled so the applications will not be started automatically"
#     echo "You can launch them manually using the launcher scripts:"
#     echo ""
#     echo "   Stable Diffusion Web UI:"
#     echo "   ---------------------------------------------"
#     echo "   /start_a1111.sh"
#     echo ""
#     echo "   Kohya_ss"
#     echo "   ---------------------------------------------"
#     echo "   /start_kohya.sh"
#     echo ""
#     echo "   ComfyUI"
#     echo "   ---------------------------------------------"
#     echo "   /start_comfyui.sh"
# else
#     /start_a1111.sh
#     /start_kohya.sh
#     /start_comfyui.sh
# fi

if [[ ! ${DISABLE_AUTOLAUNCH} ]]; then
    echo "Starting A1111 Web UI..."
    cd /stable-diffusion-webui
    nohup ./webui.sh -f > /workspace/logs/a1111.log 2>&1 &

    echo "Starting Kohya..."
    cd /kohya_ss
    nohup ./gui.sh --listen 0.0.0.0 --server_port 3011 --headless > /workspace/logs/kohya_ss.log 2>&1 &
fi

if [ ${ENABLE_TENSORBOARD} ];
then
    /start_tensorboard.sh
fi

echo "All services have been started"
