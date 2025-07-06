#!/bin/bash

# Container Setup Script
# Run this after SSH'ing into a fresh container
# Updated to use Geth 1.10.26 for PoW support

set -e

echo "🚀 Setting up blockchain container..."

# Install glibc compatibility for Alpine (required for geth)
echo "📦 Installing gcompat..."
apk add gcompat

# Download and install Geth 1.10.26 (pre-merge, supports PoW)
echo "⬇️  Downloading Geth 1.10.26..."
cd /tmp
wget https://gethstore.blob.core.windows.net/builds/geth-linux-arm64-1.10.26-e5eb32ac.tar.gz

echo "📂 Extracting Geth..."
tar -xzf geth-linux-arm64-1.10.26-e5eb32ac.tar.gz

echo "🔧 Installing Geth..."
mv geth-linux-arm64-1.10.26-e5eb32ac/geth /usr/local/bin/
chmod +x /usr/local/bin/geth

# Verify installation
echo "✅ Verifying Geth installation..."
geth version

echo ""
echo "🎉 Setup complete! Geth 1.10.26 is ready for PoW mining."
echo "📍 Next steps:"
echo "   1. Initialize blockchain: geth --datadir /blockchain/mychain init /workspace/genesis.json"
echo "   2. Start geth console: geth --datadir /blockchain/mychain --networkid 1337 --http --http.port 8545 --http.addr 0.0.0.0 --http.api \"eth,net,web3,personal,miner\" --allow-insecure-unlock console"
echo ""
echo "🔬 Experimental findings:"
echo "   - Zero address funding works for balance but not for transactions"
echo "   - Genesis allocation ≠ spendable account without private key"
echo "   - Modern Geth (1.13+) only supports PoS networks"