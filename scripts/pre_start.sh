#!/usr/bin/env bash
export PYTHONUNBUFFERED=1

# Configure accelerate
echo "Configuring accelerate..."
mkdir -p /root/.cache/huggingface/accelerate
mv /accelerate.yaml /root/.cache/huggingface/accelerate/default_config.yaml

mkdir -p /workspace/logs
mkdir -p /workspace/outputs/{a1111,kohya_ss,invokeai}

ln -fs /workspace/outputs/a1111 /stable-diffusion-webui/outputs

if [[ ! ${DISABLE_MODEL_DOWNLOAD} ]]; then
    echo "Downloading missing shared models..."
    mkdir -p /workspace/models/main

    aria2c -i /model-download-aria2.txt -j 4 -c
    echo "Linking models into A1111..."
    ln -fs /workspace/models/main/sd_xl_base_1.0_0.9vae.safetensors                 /stable-diffusion-webui/models/Stable-diffusion/sd_xl_base_1.0_0.9vae.safetensors
    ln -fs /workspace/models/main/sd_xl_refiner_1.0.safetensors                     /stable-diffusion-webui/models/Stable-diffusion/sd_xl_refiner_1.0.safetensors
    ln -fs /workspace/models/main/sd_xl_refiner_1.0_0.9vae.safetensors              /stable-diffusion-webui/models/Stable-diffusion/sd_xl_refiner_1.0_0.9vae.safetensors

    echo "Linking InvokeAI..."
    mkdir -p /workspace/invoke/{models,configs,databases}
    rsync -avP /invokeai/models/     /workspace/invoke/models/
    rsync -avP /invokeai/configs/    /workspace/invoke/configs/
    rsync -avP /invokeai/databases/  /workspace/invoke/databases/
    rm -r /invokeai/{models,configs,databases}
    ln -fs /workspace/invoke/models     /invokeai/models
    ln -fs /workspace/invoke/configs    /invokeai/configs
    ln -fs /workspace/invoke/databases  /invokeai/databases
    ln -fs /workspace/outputs/invokeai  /invokeai/outputs

    ln -fs /workspace/models/main/sd_xl_base_1.0_0.9vae.safetensors     /invokeai/autoimport/sd_xl_base_1.0_0.9vae.safetensors
    ln -fs /workspace/models/main/sd_xl_refiner_1.0_0.9vae.safetensors  /invokeai/autoimport/sd_xl_refiner_1.0_0.9vae.safetensors


    if [ ! -z ${FORCE_INVOKE_MODEL_ADD} ] || [ ! -f /workspace/invoke/models_fetched ]; then
        echo "Adding InvokeAI models..."
        cd /invokeai
        source venv/bin/activate

        # Assume that if we don't have inpaint model we didnt install the additional invoke models
        invokeai-model-install --root /invokeai --yes --add \
            diffusers/stable-diffusion-xl-1.0-inpainting-0.1 \
            diffusers/controlnet-canny-sdxl-1.0 \
            diffusers/controlnet-depth-sdxl-1.0 \
            madebyollin/sdxl-vae-fp16-fix

        touch /workspace/invoke/models_fetched
        deactivate
    fi
fi

if [[ ! ${DISABLE_TRAINING_ASSET_DOWNLOAD} ]] && [ ! -d /workspace/training-assets ]; then
    echo "Downloading training assets..."
    mkdir -p /workspace/training-assets
    [ -f /workspace/training-assets.tar.gz ] || \
        aria2c "https://hemul-share-bucket.s3.us-east-005.backblazeb2.com/training-assets.tar.gz" \
            -o /workspace/training-assets.tar.gz

    echo "Extracting training assets..."
    tar -xzf /workspace/training-assets.tar.gz -C /workspace/training-assets --no-same-owner
    rm /workspace/training-assets.tar.gz
fi
