# Stage 1: Base
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04 as base

ENV INSTALL_ROOT=/workspace/apps
ENV WEBUI_VERSION=v1.6.0
ENV DREAMBOOTH_COMMIT=cf086c536b141fc522ff11f6cffc8b7b12da04b9
ENV KOHYA_VERSION=v22.2.1
ENV INVOKEAI_VERSION=v3.4.0post2

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/London \
    PYTHONUNBUFFERED=1 \
    SHELL=/bin/bash

# Create workspace working directory
WORKDIR /

# Install Ubuntu packages
RUN apt update && \
    apt -y upgrade && \
    apt install -y --no-install-recommends \
        rclone \
        build-essential \
        software-properties-common \
        python3.10-venv \
        python3-pip \
        python3-tk \
        python3-dev \
        nodejs \
        npm \
        parallel \
        aria2 \
        bash \
        dos2unix \
        git \
        git-lfs \
        ncdu \
        net-tools \
        inetutils-ping \
        openssh-server \
        libglib2.0-0 \
        libsm6 \
        libgl1 \
        libxrender1 \
        libxext6 \
        ffmpeg \
        wget \
        curl \
        psmisc \
        rsync \
        vim \
        zip \
        unzip \
        p7zip-full \
        htop \
        pkg-config \
        plocate \
        libcairo2-dev \
        libgoogle-perftools4 \
        libtcmalloc-minimal4 \
        apt-transport-https \
        ca-certificates && \
    update-ca-certificates && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

# Set Python
RUN ln -s /usr/bin/python3.10 /usr/bin/python

# # Clone the git repo of the Stable Diffusion Web UI by Automatic1111
# # and set version
# WORKDIR /
# RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git && \
#     cd /stable-diffusion-webui && \
#     git checkout tags/${WEBUI_VERSION}

# WORKDIR /stable-diffusion-webui
# COPY a1111/requirements.txt a1111/requirements_versions.txt a1111/install-automatic.py ./
# RUN python3 -m venv --system-site-packages venv && \
#     source venv/bin/activate && \
#     pip3 install --no-cache-dir torch==2.0.1 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 && \
#     pip3 install --no-cache-dir xformers==0.0.22 tensorrt && \
#     pip3 install --no-cache-dir -r requirements_versions.txt && \
#     python3 -m install-automatic --skip-torch-cuda-test && \
#     deactivate

# # Clone the Automatic1111 Extensions
# RUN git clone https://github.com/d8ahazard/sd_dreambooth_extension.git extensions/sd_dreambooth_extension && \
#     git clone --depth=1 https://github.com/deforum-art/sd-webui-deforum.git extensions/deforum && \
#     git clone --depth=1 https://github.com/Mikubill/sd-webui-controlnet.git extensions/sd-webui-controlnet && \
#     git clone --depth=1 https://github.com/ashleykleynhans/a1111-sd-webui-locon.git extensions/a1111-sd-webui-locon && \
#     git clone --depth=1 https://github.com/Gourieff/sd-webui-reactor.git extensions/sd-webui-reactor && \
#     git clone --depth=1 https://github.com/zanllp/sd-webui-infinite-image-browsing.git extensions/infinite-image-browsing && \
#     git clone --depth=1 https://github.com/Uminosachi/sd-webui-inpaint-anything.git extensions/inpaint-anything && \
#     git clone --depth=1 https://github.com/Bing-su/adetailer.git extensions/adetailer
#     # git clone --depth=1 https://github.com/civitai/sd_civitai_extension.git extensions/sd_civitai_extension && \
#     # git clone --depth=1 https://github.com/BlafKing/sd-civitai-browser-plus.git extensions/sd-civitai-browser-plus

# # Install dependencies for Deforum, ControlNet, ReActor, Infinite Image Browsing,
# # After Detailer, and CivitAI Browser+ extensions
# RUN source venv/bin/activate && \
#     cd /stable-diffusion-webui/extensions/deforum && \
#     pip3 install -r requirements.txt && \
#     cd /stable-diffusion-webui/extensions/sd-webui-controlnet && \
#     pip3 install -r requirements.txt && \
#     cd /stable-diffusion-webui/extensions/sd-webui-reactor && \
#     pip3 install -r requirements.txt && \
#     pip3 install onnxruntime-gpu && \
#     cd /stable-diffusion-webui/extensions/infinite-image-browsing && \
#     pip3 install -r requirements.txt && \
#     cd /stable-diffusion-webui/extensions/adetailer && \
#     python3 -m install && \
#     # cd /stable-diffusion-webui/extensions/sd_civitai_extension && \
#     # pip3 install -r requirements.txt && \
#     deactivate

# # Install dependencies for inpaint anything extension
# RUN source venv/bin/activate && \
#     pip3 install segment_anything lama_cleaner && \
#     deactivate

# # Install dependencies for Civitai Browser+ extension
# # RUN source venv/bin/activate && \
# #     cd /stable-diffusion-webui/extensions/sd-civitai-browser-plus && \
# #     pip3 install send2trash ZipUnicode && \
# #     deactivate

# # Set Dreambooth extension version
# WORKDIR /stable-diffusion-webui/extensions/sd_dreambooth_extension
# RUN git checkout main && \
#     git reset ${DREAMBOOTH_COMMIT} --hard

# # Install the dependencies for the Dreambooth extension
# WORKDIR /stable-diffusion-webui
# COPY a1111/requirements_dreambooth.txt ./requirements.txt
# RUN source venv/bin/activate && \
#     cd /stable-diffusion-webui/extensions/sd_dreambooth_extension && \
#     pip3 install -r requirements.txt && \
#     deactivate

# # Add inswapper model for the ReActor extension
# RUN mkdir -p /stable-diffusion-webui/models/insightface && \
#     cd /stable-diffusion-webui/models/insightface && \
#     wget https://github.com/facefusion/facefusion-assets/releases/download/models/inswapper_128.onnx

# # Configure ReActor to use the GPU instead of the CPU
# RUN echo "CUDA" > /stable-diffusion-webui/extensions/sd-webui-reactor/last_device.txt

# # Install CivitAI Model Downloader
# # RUN git clone --depth=1 https://github.com/ashleykleynhans/civitai-downloader.git && \
# #     mv civitai-downloader/download.sh /usr/local/bin/download-model && \
# #     chmod +x /usr/local/bin/download-model

# # Copy Stable Diffusion Web UI config files
# # COPY a1111/relauncher.py a1111/webui-user.sh a1111/config.json a1111/ui-config.json /stable-diffusion-webui/
# COPY a1111/webui-user.sh a1111/config.json a1111/ui-config.json /stable-diffusion-webui/

# ADD SDXL styles.csv
ADD https://raw.githubusercontent.com/Douleb/SDXL-750-Styles-GPT4-/main/styles.csv /config/styles.csv

# Install VS Server
RUN curl -fsSL https://code-server.dev/install.sh | sh && \
    code-server --install-extension enkia.tokyo-night \
        --install-extension ms-python.python \
        --install-extension foxx1337.autoscrolldown

COPY /vs-server/settings.json /vs-server/settings.json 

# Install runpodctl
RUN wget https://github.com/runpod/runpodctl/releases/download/v1.10.0/runpodctl-linux-amd -O runpodctl && \
    chmod a+x runpodctl && \
    mv runpodctl /usr/local/bin

# Install speedtest CLI
RUN curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash && \
    apt install speedtest

# Remove existing SSH host keys
RUN rm -f /etc/ssh/ssh_host_*

WORKDIR /

# Copy the scripts
COPY --chmod=755 scripts/* ./
COPY model-download-aria2.txt /

COPY invokeai/invokeai.yaml /config/invokeai/invokeai.yaml
COPY kohya_ss/requirements* /config/kohya_ss/

# Copy the accelerate configuration
COPY kohya_ss/accelerate.yaml ./

VOLUME [ "/workspace" ]
EXPOSE 3000 3010 6006 8080 9090

# Start the container
SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/start.sh" ]