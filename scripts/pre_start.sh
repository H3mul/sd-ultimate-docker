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

# Configure accelerate
echo "Configuring accelerate..."
mkdir -p /root/.cache/huggingface/accelerate
mv /accelerate.yaml /root/.cache/huggingface/accelerate/default_config.yaml

# Create logs directory
mkdir -p /workspace/logs

mkdir -p /workspace/outputs/{a1111,kohya_ss,invokeai}

ln -s /workspace/outputs/a1111 /stable-diffusion-webui/outputs

ln -s /models/stable-diffusion/sd_xl_base_1.0.safetensors       /stable-diffusion-webui/models/Stable-diffusion/sd_xl_base_1.0.safetensors
ln -s /models/stable-diffusion/sd_xl_refiner_1.0.safetensors    /stable-diffusion-webui/models/Stable-diffusion/sd_xl_refiner_1.0.safetensors
ln -s /models/vae/sdxl_vae.safetensors                          /stable-diffusion-webui/models/VAE/sdxl_vae.safetensors

ln -s /workspace/outputs/invokeai /invokeai/outputs

mkdir -p /invokeai/autoimport/{main,vae}
ln -s /models/stable-diffusion/sd_xl_base_1.0.safetensors       /invokeai/autoimport/main/sd_xl_base_1.0.safetensors
ln -s /models/stable-diffusion/sd_xl_refiner_1.0.safetensors    /invokeai/autoimport/main/sd_xl_refiner_1.0.safetensors
ln -s /models/vae/sdxl_vae.safetensors                          /invokeai/autoimport/vae/sdxl_vae.safetensors

if [[ ! ${DISABLE_AUTOLAUNCH} ]]; then
    /start_a1111.sh
    /start_kohya.sh
    /start_invokeai.sh
fi

if [ ${ENABLE_TENSORBOARD} ];
then
    /start_tensorboard.sh
fi

echo "All services have been started"
