FROM ubuntu:22.04

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    curl \
    git \
    python3 \
    python3-pip \
    vim \
    wget \
    tmux \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Install tmate and its dependencies
RUN apt-get update && apt-get install -y \
    tmate \
    automake \
    pkg-config \
    libtool \
    libevent-dev \
    libncurses-dev \
    libssl-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Configure SSH
RUN mkdir /var/run/sshd
RUN echo 'root:Docker!' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Create a new user
RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1000 ubuntu
RUN echo 'ubuntu:ubuntu' | chpasswd

# Set up tmate configuration directory
RUN mkdir -p /home/ubuntu/.config/tmate
RUN chown -R ubuntu:root /home/ubuntu/.config

# Generate SSH keys for tmate
RUN mkdir -p /home/ubuntu/.ssh
RUN ssh-keygen -t rsa -f /home/ubuntu/.ssh/id_rsa -N ""
RUN chown -R ubuntu:root /home/ubuntu/.ssh

WORKDIR /home/ubuntu

# Copy tmate setup script and entrypoint
COPY setup-tmate.sh /usr/local/bin/
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup-tmate.sh /usr/local/bin/entrypoint.sh

EXPOSE 22

# Use entrypoint script to start both SSH and tmate
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"] 