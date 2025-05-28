# Required by InvokeAI (<3.12)
# https://github.com/invoke-ai/InvokeAI/blob/bbd89d54b48397c65edc32fbdaa07564eee33298/pyproject.toml#L8C21-L8C34

FROM python:3.11@sha256:4e0b4f7d6124f7ff41cdc1b82bedaa07722c55fbb78038c7587b5f7c0b892c1a

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
        nodejs \
        npm \
        parallel \
        aria2 \
        bash \
        dos2unix \
        git \
        cmake \
        libncurses5-dev \
        libncursesw5-dev \
        libudev-dev \
        libdrm-dev \
        libsystemd-dev \
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
        pslist \
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
        python3-launchpadlib \
        less \
        ca-certificates && \
    update-ca-certificates && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

RUN git clone https://github.com/Syllo/nvtop.git /app/nvtop && \
    mkdir -p /app/nvtop/build && cd /app/nvtop/build && \
    cmake .. -DNVIDIA_SUPPORT=ON -DAMDGPU_SUPPORT=ON -DINTEL_SUPPORT=ON && \
    make && \
    make install && \
    ln -fs /app/nvtop/build/src/nvtop /usr/bin/nvtop

# ADD SDXL styles.csv
ADD https://raw.githubusercontent.com/Douleb/SDXL-750-Styles-GPT4-/main/styles.csv /config/styles.csv

# Install VS Server
RUN curl -fsSL https://code-server.dev/install.sh | sh && \
    code-server --install-extension enkia.tokyo-night \
        --install-extension ms-python.python

COPY /vs-server/settings.json /vs-server/settings.json 

# Install runpodctl
RUN wget https://github.com/runpod/runpodctl/releases/download/v1.10.0/runpodctl-linux-amd -O runpodctl && \
    chmod a+x runpodctl && \
    mv runpodctl /usr/local/bin

# Install speedtest CLI
RUN curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash && \
    apt install speedtest


RUN pip install uv

# Remove existing SSH host keys
RUN rm -f /etc/ssh/ssh_host_*
RUN mkdir -p /app/{pid,config,scripts}

WORKDIR /

# Copy the scripts
COPY --chmod=755 scripts/* /app/scripts/
COPY model-download-aria2.txt /app/config/

COPY invokeai/invokeai.yaml /app/config/invokeai/invokeai.yaml
COPY a1111/* /app/config/a1111/
COPY kohya_ss/* /app/config/kohya_ss/

ENV PATH=${PATH}:/app/scripts

ENV INSTALL_ROOT=/workspace/apps

# renovate: datasource=github-releases depName=bmaltais/kohya_ss
ENV KOHYA_VERSION=v25.1.2
ENV ENABLE_KOHYA=false
ENV KOHYA_ROOT="${INSTALL_ROOT}/kohya_ss"
ENV KOHYA_PORT=3000

# renovate: datasource=github-releases depName=invoke-ai/InvokeAI
ENV INVOKEAI_VERSION=v5.12.0
# renovate: datasource=pypi depName=InvokeAI
ENV INVOKEAI_PYPI_VERSION=5.12.0
ENV ENABLE_INVOKEAI=false
ENV INVOKEAI_ROOT="${INSTALL_ROOT}/invokeai"
ENV INVOKEAI_PORT=9090

# renovate: datasource=github-releases depName=AUTOMATIC1111/stable-diffusion-webui
ENV A1111_VERSION=v1.10.1
ENV ENABLE_A1111=false
ENV DREAMBOOTH_COMMIT=1.1.0
ENV A1111_ROOT="${INSTALL_ROOT}/a1111"
ENV A1111_PORT=3000

# renovate: datasource=github-releases depName=comfyanonymous/ComfyUI
ENV COMFYUI_VERSION=v0.3.36
ENV ENABLE_COMFYUI=false
ENV COMFYUI_ROOT="${INSTALL_ROOT}/comfyui"
ENV COMFYUI_PORT=8188

ENV DISABLE_MODEL_DOWNLOAD=false
ENV SHUTDOWN_AFTER_PROVISION=false
ENV SHUTDOWN_AFTER_TRAINING=false
ENV DISABLE_AUTOLAUNCH=false
ENV PUSHBULLET_API_TOKEN=""
ENV NOTIFY_ON_TRAINING_END=false

# Slows down bootup but save space (quite a bit of space, ~20Gb usually)
ENV CLEAR_CACHE_ON_SHUTDOWN=true

# Matches most kohya training scripts,
# eg sdxl_train_network.py, sdxl_train.py, train_network.py, etc
ENV TRAINING_PID_PATTERN="train.*\.py"

ENV VS_CODE_PORT=3000

VOLUME [ "/workspace" ]
EXPOSE ${A1111_PORT} ${KOHYA_PORT} ${VS_CODE_PORT} ${INVOKEAI_PORT} ${COMFYUI_PORT}

# Start the container
SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/app/scripts/start.sh" ]