FROM ubuntu:22.04

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    sudo \
    curl \
    wget \
    git \
    net-tools \
    systemd \
    systemd-sysv \
    && rm -rf /var/lib/apt/lists/*

# Create a new user
RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1000 ubuntu
RUN echo 'ubuntu:ubuntu' | chpasswd

WORKDIR /home/ubuntu

# Install CasaOS
RUN curl -fsSL https://get.casaos.io | bash

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose ports for CasaOS
EXPOSE 80 443

# Use systemd as entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"] 