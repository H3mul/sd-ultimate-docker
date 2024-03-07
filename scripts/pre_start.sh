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
wait
echo "All app installs complete"

mkdir -p /workspace/logs

if [ "${DISABLE_MODEL_DOWNLOAD}" != true ]; then
    echo "Downloading missing shared models..."
    mkdir -p /workspace/models/main
    aria2c -i /app/config/model-download-aria2.txt -j 4 -c

    # echo "Linking models into A1111..."
    ln -fs /workspace/models/main/sd_xl_base_1.0_0.9vae.safetensors     ${A1111_ROOT}/models/Stable-diffusion/sd_xl_base_1.0_0.9vae.safetensors
    ln -fs /workspace/models/main/sd_xl_refiner_1.0_0.9vae.safetensors  ${A1111_ROOT}/models/Stable-diffusion/sd_xl_refiner_1.0_0.9vae.safetensors

    echo "Linking InvokeAI..."
    ln -fs /workspace/models/main/sd_xl_base_1.0_0.9vae.safetensors     ${INVOKEAI_ROOT}/autoimport/sd_xl_base_1.0_0.9vae.safetensors
    ln -fs /workspace/models/main/sd_xl_refiner_1.0_0.9vae.safetensors  ${INVOKEAI_ROOT}/autoimport/sd_xl_refiner_1.0_0.9vae.safetensors
fi
