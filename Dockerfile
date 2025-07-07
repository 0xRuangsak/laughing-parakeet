FROM alpine:latest

# Install SSH, basic tools, and blockchain development tools
RUN apk add --no-cache \
    openssh \
    curl \
    wget \
    vim \
    nano \
    gcompat \
    solidity

# Set up SSH
RUN ssh-keygen -A
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
RUN echo 'PermitEmptyPasswords yes' >> /etc/ssh/sshd_config
RUN passwd -d root

# Download and install Geth 1.10.26 (pre-merge, supports PoW)
RUN cd /tmp && \
    wget https://gethstore.blob.core.windows.net/builds/geth-linux-arm64-1.10.26-e5eb32ac.tar.gz && \
    tar -xzf geth-linux-arm64-1.10.26-e5eb32ac.tar.gz && \
    mv geth-linux-arm64-1.10.26-e5eb32ac/geth /usr/local/bin/ && \
    chmod +x /usr/local/bin/geth && \
    rm -rf /tmp/*

# Verify installations
RUN geth version
RUN solc --version

# Create working directory
WORKDIR /blockchain

# Expose SSH port
EXPOSE 22

# Start SSH service
CMD ["/usr/sbin/sshd", "-D"]