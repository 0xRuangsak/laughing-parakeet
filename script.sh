
```bash
# Download the official ARM64 Geth binary
cd /tmp
wget https://gethstore.blob.core.windows.net/builds/geth-linux-arm64-1.15.11-36b2371c.tar.gz

# Extract the archive
tar -xzf geth-linux-arm64-1.15.11-36b2371c.tar.gz

# Move geth to system path
mv geth-linux-arm64-1.15.11-36b2371c/geth /usr/local/bin/

# Make it executable
chmod +x /usr/local/bin/geth

# Check what libraries geth needs
ldd /usr/bin/geth

# Install glibc compatibility for Alpine
apk add gcompat

# Test the installation
geth version
```
