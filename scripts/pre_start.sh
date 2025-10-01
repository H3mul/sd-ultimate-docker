#!/usr/bin/env bash
set -eu

export PYTHONUNBUFFERED=1

# Configure accelerate
echo "Configuring accelerate..."
mkdir -p /root/.cache/huggingface/accelerate
cp /app/config/kohya_ss/accelerate.yaml /root/.cache/huggingface/accelerate/default_config.yaml

echo "Setting the app install root to ${INSTALL_ROOT}"
mkdir -p ${INSTALL_ROOT}

echo "Starting app provision in parallel..."
[ "${ENABLE_INVOKEAI}" == true ] && provision_invokeai.sh &
[ "${ENABLE_KOHYA}" == true ] && provision_kohya.sh &
[ "${ENABLE_A1111}" == true ] && provision_a1111.sh &
[ "${ENABLE_COMFYUI}" == true ] && provision_comfyui.sh &
[ "${ENABLE_FLUXGYM}" == true ] && provision_fluxgym.sh &
wait
echo "All app installs complete"

mkdir -p /workspace/logs

if [ "${DISABLE_MODEL_DOWNLOAD}" != true ]; then
    echo "Downloading missing shared models..."

    cd /
    mkdir -p /workspace/models/main

    echo "Downloading models..."
    aria2c -i /app/config/model-download-aria2.txt -j 4 -c

    if [ -f  /workspace/download-aria2.txt ]; then
        echo "Downloading any additional files from /workspace/download-aria2.txt..."
        aria2c -i /workspace/download-aria2.txt -j 4 -c
    fi

    set +e

    if [ -d "${A1111_ROOT}" ]; then
        echo "Linking models into A1111..."
        ln -fs /workspace/models/sdxl/sd_xl_base_1.0_0.9vae.safetensors     ${A1111_ROOT}/models/Stable-diffusion/sd_xl_base_1.0_0.9vae.safetensors
        ln -fs /workspace/models/sdxl/sd_xl_refiner_1.0_0.9vae.safetensors  ${A1111_ROOT}/models/Stable-diffusion/sd_xl_refiner_1.0_0.9vae.safetensors
    fi

    if [ -d "${INVOKEAI_ROOT}" ]; then
        echo "Linking InvokeAI..."
        ln -fs /workspace/models/sdxl/sd_xl_base_1.0_0.9vae.safetensors     ${INVOKEAI_ROOT}/autoimport/sd_xl_base_1.0_0.9vae.safetensors
        ln -fs /workspace/models/sdxl/sd_xl_refiner_1.0_0.9vae.safetensors  ${INVOKEAI_ROOT}/autoimport/sd_xl_refiner_1.0_0.9vae.safetensors

        for model in /workspace/models/flux/*; do
            ln -fs ${model} ${INVOKEAI_ROOT}/autoimport/${model}
        done
    fi

    if [ -d "${COMFYUI_ROOT}" ]; then
        echo "Linking ComfyUI..."
        ln -fs /workspace/models/sdxl/sd_xl_base_1.0_0.9vae.safetensors     ${COMFYUI_ROOT}/models/checkpoints/sd_xl_base_1.0_0.9vae.safetensors
        ln -fs /workspace/models/sdxl/sd_xl_refiner_1.0_0.9vae.safetensors  ${COMFYUI_ROOT}/models/checkpoints/sd_xl_refiner_1.0_0.9vae.safetensors

        ln -fs /workspace/models/flux/flux1-dev-fp8.safetensors             ${COMFYUI_ROOT}/models/checkpoints/flux1-dev-fp8.safetensors
        ln -fs /workspace/models/flux/flux.1-shnell.ae.safetensors          ${COMFYUI_ROOT}/models/vae/flux.1-shnell.ae.safetensors

        if [ -f /workspace/models/flux/flux1-dev.safetensors ]; then
            ln -fs /workspace/models/flux/flux1-dev.safetensors             ${COMFYUI_ROOT}/models/unet/flux1-dev.safetensors
        fi

        ln -fs /workspace/models/clip/t5xxl_fp16.safetensors                ${COMFYUI_ROOT}/models/clip/t5xxl_fp16.safetensors
        ln -fs /workspace/models/clip/clip_l.safetensors                    ${COMFYUI_ROOT}/models/clip/clip_l.safetensors
        ln -fs /workspace/models/flux/flux.1-shnell.ae.safetensors          ${COMFYUI_ROOT}/models/vae/flux.1-shnell.ae.safetensors

        ln -fs /workspace/models/flux/flux-canny-controlnet-v3.safetensors  ${COMFYUI_ROOT}/models/xlabs/controlnets/flux-canny-controlnet-v3.safetensors
        ln -fs /workspace/models/flux/flux-depth-controlnet-v3.safetensors  ${COMFYUI_ROOT}/models/xlabs/controlnets/flux-depth-controlnet-v3.safetensors
        ln -fs /workspace/models/flux/flux-hed-controlnet-v3.safetensors    ${COMFYUI_ROOT}/models/xlabs/controlnets/flux-hed-controlnet-v3.safetensors
    fi

    set -e
fi

echo "Pre-Start complete!"
