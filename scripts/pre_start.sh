#!/usr/bin/env bash
export PYTHONUNBUFFERED=1

# Configure accelerate
echo "Configuring accelerate..."
mkdir -p /root/.cache/huggingface/accelerate
mv /accelerate.yaml /root/.cache/huggingface/accelerate/default_config.yaml

mkdir -p /workspace/logs
mkdir -p /workspace/outputs/{a1111,kohya_ss,invokeai}

ln -s /workspace/outputs/a1111 /stable-diffusion-webui/outputs
ln -s /workspace/outputs/invokeai /invokeai/outputs

if [[ ! ${DISABLE_MODEL_DOWNLOAD} ]]; then
    echo "Downloading missing models..."
    mkdir -p /workspace/models/{main,vae,controlnet}
    parallel -C '\s+' --lb -j 5 -a /model-download.txt wget -c -q --show-progress --progress=bar -O {1} {2}

    echo "Linking models into services..."
    ln -fs /workspace/models/main/sd_xl_base_1.0.safetensors             /stable-diffusion-webui/models/Stable-diffusion/sd_xl_base_1.0.safetensors
    ln -fs /workspace/models/main/sd_xl_refiner_1.0.safetensors          /stable-diffusion-webui/models/Stable-diffusion/sd_xl_refiner_1.0.safetensors
    ln -fs /workspace/models/main/sd_xl-1.0-inpainting-0.1.safetensors   /stable-diffusion-webui/models/Stable-diffusion/sd_xl-1.0-inpainting-0.1.safetensors
    ln -fs /workspace/models/vae/sdxl_vae_fp16_fix.safetensors           /stable-diffusion-webui/models/VAE/sdxl_vae_fp16_fix.safetensors
    ln -fs /workspace/models/controlnet/controlnet-canny-sdxl-1.0.safetensors       /stable-diffusion-webui/models/ControlNet/controlnet-canny-sdxl-1.0.safetensors
    ln -fs /workspace/models/controlnet/controlnet-canny-sdxl-1.0-fp16.safetensors  /stable-diffusion-webui/models/ControlNet/controlnet-canny-sdxl-1.0-fp16.safetensors
    ln -fs /workspace/models/controlnet/controlnet-depth-sdxl-1.0.safetensors       /stable-diffusion-webui/models/ControlNet/controlnet-depth-sdxl-1.0.safetensors
    ln -fs /workspace/models/controlnet/controlnet-depth-sdxl-1.0-fp16.safetensors  /stable-diffusion-webui/models/ControlNet/controlnet-depth-sdxl-1.0-fp16.safetensors

    mkdir -p /invokeai/autoimport/{main,vae,controlnet}
    ln -fs /workspace/models/stable-diffusion/sd_xl_base_1.0.safetensors         /invokeai/autoimport/main/sd_xl_base_1.0.safetensors
    ln -fs /workspace/models/stable-diffusion/sd_xl_refiner_1.0.safetensors      /invokeai/autoimport/main/sd_xl_refiner_1.0.safetensors
    ln -fs /workspace/models/main/sd_xl-1.0-inpainting-0.1.safetensors           /invokeai/autoimport/main/sd_xl-1.0-inpainting-0.1.safetensors
    ln -fs /workspace/models/vae/sdxl_vae_fp16_fix.safetensors                   /invokeai/autoimport/vae/sdxl_vae_fp16_fix.safetensors
    ln -fs /workspace/models/controlnet/controlnet-canny-sdxl-1.0.safetensors       /invokeai/autoimport/controlnet/controlnet-canny-sdxl-1.0.safetensors
    ln -fs /workspace/models/controlnet/controlnet-canny-sdxl-1.0-fp16.safetensors  /invokeai/autoimport/controlnet/controlnet-canny-sdxl-1.0-fp16.safetensors
    ln -fs /workspace/models/controlnet/controlnet-depth-sdxl-1.0.safetensors       /invokeai/autoimport/controlnet/controlnet-depth-sdxl-1.0.safetensors
    ln -fs /workspace/models/controlnet/controlnet-depth-sdxl-1.0-fp16.safetensors  /invokeai/autoimport/controlnet/controlnet-depth-sdxl-1.0-fp16.safetensors
fi
