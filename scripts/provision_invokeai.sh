#!/usr/bin/env bash
set -eu

[ -d ${INVOKEAI_ROOT} ] || git clone https://github.com/invoke-ai/InvokeAI.git ${INVOKEAI_ROOT}

cd ${INVOKEAI_ROOT}

git fetch --tags
git checkout ${INVOKEAI_VERSION}

if [ -f install_complete ]; then 
    echo "install_complete flag file found, skipping InvokeAI install..."
    exit
fi

[ -d venv ] || python3 -m venv --system-site-packages venv

source venv/bin/activate
pip3 install "InvokeAI[xformers]" --use-pep517 --extra-index-url https://download.pytorch.org/whl/cu121

[ -f invokeai.yaml ] || cp /config/invokeai/invokeai.yaml ./invokeai.yaml

echo "Configuring InvokeAI..."
invokeai-configure --root ${INVOKEAI_ROOT} --yes --default_only --skip-sd-weights
echo "Installing additional InvokeAI models..."
invokeai-model-install --root ${INVOKEAI_ROOT} --yes --add \
    diffusers/stable-diffusion-xl-1.0-inpainting-0.1 \
    diffusers/controlnet-canny-sdxl-1.0 \
    diffusers/controlnet-depth-sdxl-1.0 \
    madebyollin/sdxl-vae-fp16-fix
deactivate
touch install_complete