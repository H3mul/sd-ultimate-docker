#!/usr/bin/env bash
export PYTHONUNBUFFERED=1

# Configure accelerate
echo "Configuring accelerate..."
mkdir -p /root/.cache/huggingface/accelerate
mv /accelerate.yaml /root/.cache/huggingface/accelerate/default_config.yaml

echo "Setting the app install root to ${INSTALL_ROOT}"
mkdir -p ${INSTALL_ROOT}
export KOHYA_ROOT="${INSTALL_ROOT}/kohya_ss"
export INVOKEAI_ROOT="${INSTALL_ROOT}/invokeai"
export A1111_ROOT="${INSTALL_ROOT}/a1111"

[ -d ${INVOKEAI_ROOT} ] || /install_invoke.sh
[ -d ${KOHYA_ROOT} ]    || /install_kohya.sh

ln -fs /workspace/outputs/invokeai  ${INVOKEAI_ROOT}/outputs

mkdir -p /workspace/logs

if [[ ! ${DISABLE_MODEL_DOWNLOAD} ]]; then
    echo "Downloading missing shared models..."
    mkdir -p /workspace/models/main
    aria2c -i /model-download-aria2.txt -j 4 -c

    # echo "Linking models into A1111..."
    # ln -fs /workspace/models/main/sd_xl_base_1.0_0.9vae.safetensors     ${A1111_ROOT}/models/Stable-diffusion/sd_xl_base_1.0_0.9vae.safetensors
    # ln -fs /workspace/models/main/sd_xl_refiner_1.0_0.9vae.safetensors  ${A1111_ROOT}/models/Stable-diffusion/sd_xl_refiner_1.0_0.9vae.safetensors

    echo "Linking InvokeAI..."
    ln -fs /workspace/models/main/sd_xl_base_1.0_0.9vae.safetensors     ${INVOKEAI_ROOT}/autoimport/sd_xl_base_1.0_0.9vae.safetensors
    ln -fs /workspace/models/main/sd_xl_refiner_1.0_0.9vae.safetensors  ${INVOKEAI_ROOT}/autoimport/sd_xl_refiner_1.0_0.9vae.safetensors
fi

if [[ ! ${DISABLE_TRAINING_ASSET_DOWNLOAD} ]] && [ ! -d /workspace/training-assets ]; then
    echo "Downloading training assets..."
    mkdir -p /workspace/training-assets
    [ -f /workspace/training-assets.tar.gz ] || \
        aria2c "https://hemul-share-bucket.s3.us-east-005.backblazeb2.com/training-assets.tar.gz" \
            -o /workspace/training-assets.tar.gz

    echo "Extracting training assets..."
    tar -xvzf /workspace/training-assets.tar.gz -C /workspace/training-assets --no-same-owner
    rm /workspace/training-assets.tar.gz
fi
