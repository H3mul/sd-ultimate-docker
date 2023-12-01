#!/usr/bin/env bash
export PYTHONUNBUFFERED=1

# Configure accelerate
echo "Configuring accelerate..."
mkdir -p /root/.cache/huggingface/accelerate
mv /accelerate.yaml /root/.cache/huggingface/accelerate/default_config.yaml

mkdir -p /workspace/logs
mkdir -p /workspace/outputs/{a1111,kohya_ss,invokeai}

ln -fs /workspace/outputs/a1111 /stable-diffusion-webui/outputs
ln -fs /workspace/outputs/invokeai /invokeai/outputs

if [[ ! ${DISABLE_MODEL_DOWNLOAD} ]]; then
    echo "Downloading missing models..."
    mkdir -p /workspace/models/{main,vae,controlnet}
    aria2c -i /model-download-aria2.txt -j 4 -c

    echo "Linking models into services..."
    ln -fs /workspace/models/main/sd_xl-base-1.0/diffusion_pytorch_model.safetensors            /stable-diffusion-webui/models/Stable-diffusion/sd_xl-base-1.0.safetensors
    ln -fs /workspace/models/main/sd_xl-refiner-1.0/diffusion_pytorch_model.safetensors         /stable-diffusion-webui/models/Stable-diffusion/sd_xl-refiner-1.0.safetensors
    ln -fs /workspace/models/main/sd_xl-1.0-inpainting-0.1/diffusion_pytorch_model.safetensors  /stable-diffusion-webui/models/Stable-diffusion/sd_xl-1.0-inpainting-0.1.safetensors

    # ln -fs /workspace/models/vae/sdxl_vae_fp16_fix/diffusion_pytorch_model.safetensors /stable-diffusion-webui/models/VAE/sdxl_vae_fp16_fix.safetensors

    # ln -fs /workspace/models/controlnet/controlnet-canny-sdxl-1.0.safetensors       /stable-diffusion-webui/models/ControlNet/controlnet-canny-sdxl-1.0.safetensors
    # ln -fs /workspace/models/controlnet/controlnet-canny-sdxl-1.0-fp16.safetensors  /stable-diffusion-webui/models/ControlNet/controlnet-canny-sdxl-1.0-fp16.safetensors
    # ln -fs /workspace/models/controlnet/controlnet-depth-sdxl-1.0.safetensors       /stable-diffusion-webui/models/ControlNet/controlnet-depth-sdxl-1.0.safetensors
    # ln -fs /workspace/models/controlnet/controlnet-depth-sdxl-1.0-fp16.safetensors  /stable-diffusion-webui/models/ControlNet/controlnet-depth-sdxl-1.0-fp16.safetensors

    mkdir -p /invokeai/autoimport/{main,vae,controlnet}
    ln -fs /workspace/models/main/sd_xl-base-1.0                    /invokeai/models/sdxl/main/sd_xl-base-1.0
    ln -fs /workspace/models/main/sd_xl-refiner-1.0                 /invokeai/models/sdxl/main/sd_xl-refiner-1.0
    ln -fs /workspace/models/main/sd_xl-1.0-inpainting-0.1          /invokeai/models/sdxl/main/sd_xl-1.0-inpainting-0.1
    ln -fs /workspace/models/vae/sdxl_vae_fp16_fix                  /invokeai/models/sdxl/vae/sdxl_vae_fp16_fix
    ln -fs /workspace/models/controlnet/controlnet-canny-sdxl-1.0   /invokeai/models/sdxl/controlnet/controlnet-canny-sdxl-1.0
    ln -fs /workspace/models/controlnet/controlnet-depth-sdxl-1.0   /invokeai/models/sdxl/controlnet/controlnet-depth-sdxl-1.0

fi

if [[ ! ${DISABLE_TRAINING_ASSET_DOWNLOAD} ]] && [ ! -d /workspace/training-assets ]; then
    echo "Downloading training assets..."
    mkdir -p /workspace/training-assets
    [ -f /workspace/training-assets.tar.gz ] || \
        aria2c "https://hemul-share-bucket.s3.us-east-005.backblazeb2.com/training-assets.tar.gz" \
            -o /workspace/training-assets.tar.gz

    echo "Extracting training assets..."
    tar -xzf /workspace/training-assets.tar.gz -C /workspace/training-assets
    rm /workspace/training-assets.tar.gz
fi
