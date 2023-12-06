# Stage 1: Base
FROM python:3.10

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

ENV INSTALL_ROOT=/workspace/apps
ENV KOHYA_ROOT="${INSTALL_ROOT}/kohya_ss"
ENV INVOKEAI_ROOT="${INSTALL_ROOT}/invokeai"

ENV WEBUI_VERSION=v1.6.0
ENV DREAMBOOTH_COMMIT=cf086c536b141fc522ff11f6cffc8b7b12da04b9
ENV KOHYA_VERSION=v22.2.2
ENV INVOKEAI_VERSION=v3.4.0post2

ENV DISABLE_MODEL_DOWNLOAD=false
ENV DISABLE_TRAINING_ASSET_DOWNLOAD=false
ENV SHUTDOWN_AFTER_PROVISION=false
ENV DISABLE_AUTOLAUNCH=false
ENV POD_TERMINATION_PID_PATTERN=train.py

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