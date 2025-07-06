#!/bin/bash

# Container Setup Script
# Run this after SSH'ing into a fresh container

set -e

echo "🚀 Setting up blockchain container..."

# Install glibc compatibility for Alpine (required for geth)
echo "📦 Installing gcompat..."
apk add gcompat

# Download and install Geth
echo "⬇️  Downloading Geth..."
cd /tmp
wget https://gethstore.blob.core.windows.net/builds/geth-linux-arm64-1.15.11-36b2371c.tar.gz

echo "📂 Extracting Geth..."
tar -xzf geth-linux-arm64-1.15.11-36b2371c.tar.gz

echo "🔧 Installing Geth..."
mv geth-linux-arm64-1.15.11-36b2371c/geth /usr/local/bin/
chmod +x /usr/local/bin/geth

# Verify installation
echo "✅ Verifying Geth installation..."
geth version

echo ""
echo "🎉 Setup complete! Geth is ready to use."
echo "📍 Next steps:"
echo "   1. Initialize blockchain: geth init /workspace/genesis.json --datadir /blockchain/mychain"
echo "   2. Start geth console: geth --datadir /blockchain/mychain --networkid 1337 --http --http.port 8545 --http.addr 0.0.0.0 --http.api \"eth,net,web3,personal,miner\" --allow-insecure-unlock console"