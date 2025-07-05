FROM alpine:latest

# Install SSH and basic tools
RUN apk add --no-cache \
    openssh \
    curl \
    wget \
    vim \
    nano

# Set up SSH
RUN ssh-keygen -A
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
RUN echo 'PermitEmptyPasswords yes' >> /etc/ssh/sshd_config
RUN passwd -d root

# Create working directory
WORKDIR /blockchain

# Expose SSH port
EXPOSE 22

# Start SSH service
CMD ["/usr/sbin/sshd", "-D"]