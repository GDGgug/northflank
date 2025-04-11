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
    && rm -rf /var/lib/apt/lists/*

# Install tmate
RUN apt-get update && apt-get install -y \
    tmate \
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

WORKDIR /home/ubuntu

# Copy tmate setup script
COPY setup-tmate.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup-tmate.sh

EXPOSE 22

# Start SSH service and keep container running
CMD ["/usr/sbin/sshd", "-D"] 