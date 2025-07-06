# Minimal Alpine Blockchain Container

## Project Scope & Purpose

This project creates a minimal containerized environment for blockchain experimentation using Geth (Go Ethereum). The setup is designed for learning and testing blockchain concepts, smart contract deployment, and manual block creation.

### Key Requirements & Decisions Made:
- **Platform**: Mac with Docker Compose V2 (`docker compose` not `docker-compose`) - CRITICAL: User explicitly cannot run `docker-compose` (old syntax) and MUST use `docker compose` (new syntax)
- **Base Image**: Alpine Linux (lightweight, minimal footprint) - Chosen over Ubuntu/Debian after discussion about size vs familiarity tradeoffs
- **Access Method**: SSH as root with no password for simplicity - User specifically requested root access with no authentication complexity
- **Installation Philosophy**: Nothing pre-installed - install geth and tools as needed inside container - User explicitly wants clean container to install everything manually for learning
- **Data Strategy**: Everything stays in container (no host mounts for simplicity) - User explicitly declined persistent storage to host filesystem
- **Network**: Basic SSH port, additional ports added later as needed - Start minimal, expand as required
- **Block Creation**: Manual mining - blocks created only on command, not automatic - This is crucial for smart contract testing workflow
- **Smart Contracts**: Deploy and test with full control over when transactions are mined
- **Workflow**: Start container in foreground (`docker compose up`), open another terminal to SSH in - User explicitly rejected background (-d) mode, prefers simple foreground + new terminal approach

### Critical Workflow Requirements:
- User wants to run `docker compose up` (foreground, no -d flag)
- User will open a separate terminal window to SSH into container
- User does NOT want background daemon management
- User wants complete manual control over all installations and configurations
- User wants to experiment with manual block creation for precise transaction control

### Workflow Philosophy:
1. Start container in foreground (`docker compose up`)
2. Open another terminal to SSH in
3. Install geth manually
4. Set up blockchain exactly as desired
5. Experiment with manual block creation for precise control
6. Deploy smart contracts with controlled mining

This approach avoids assumptions and gives complete control over the environment setup.

## Setup Instructions

### File Structure Required:
```
blockchain-container/
├── Dockerfile          (Alpine + SSH configuration)
├── docker-compose.yml  (Container orchestration + workspace mount)
├── README.md           (This file - comprehensive documentation)
├── DECISIONS.md        (Architecture decisions and rationale)
├── PROGRESS.md         (Project timeline and status)
├── QUICKSTART.md       (Essential commands only)
└── workspace/          (Development files - edit on Mac, sync to container)
    └── .gitkeep        (Keeps empty folder in git)
```

**Note**: DECISIONS.md and PROGRESS.md contain critical context for future LLM conversations.

1. **Create project directory:**
```bash
mkdir blockchain-container
cd blockchain-container
```

2. **Create workspace folder:**
```bash
mkdir workspace
```

3. **Save the Dockerfile and docker-compose.yml** from the artifacts above

4. **Build and start container:**
```bash
docker compose build
docker compose up
```
(Keep this terminal open - container runs in foreground)

5. **Open new terminal and SSH into container:**
```bash
ssh root@localhost -p 2222
```
(No password required - just press Enter)

**Keep the first terminal open with `docker compose up` running**

## Inside the Container

You now have a clean Alpine Linux environment ready for your blockchain experimentation. The container includes:
- Alpine Linux base system
- SSH server configured for root access (no password)
- Basic tools: curl, wget, vim, nano
- Working directory: `/blockchain`
- Workspace directory: `/workspace` (mounted from your Mac's `./workspace` folder)

**What's NOT included (install as needed):**
- Geth (install manually)
- Smart contract development tools
- Additional development packages

**Development Workflow:**
- Edit files on your Mac in the `workspace/` folder (fast)
- Files automatically appear in `/workspace` inside the container
- Use container for running geth and blockchain commands

### Why Manual Block Creation?
Manual block creation is perfect for blockchain experimentation because:
- **Smart Contract Testing**: Deploy contract → mine block → call function → mine block → see results
- **Transaction Control**: See pending transactions before they're mined
- **Step-by-Step Learning**: Understand exactly when state changes occur
- **Debugging**: Isolate issues by controlling when blocks are created
- **No Waiting**: Don't wait for automatic block times, create blocks when ready

### Smart Contract Development Workflow with Manual Mining:
1. Deploy smart contract - transaction sits in mempool
2. Check pending transactions: `eth.pendingTransactions`
3. Mine one block to include deployment: `miner.start(1); admin.sleepBlocks(1); miner.stop()`
4. Contract is now deployed and available
5. Call contract functions - these also sit in mempool until mined
6. Mine blocks as needed to process function calls
7. Read-only view functions work immediately without mining

### Manual Block Creation Examples
In the geth console:
```javascript
// Check pending transactions (includes contract deployments, function calls)
eth.pendingTransactions

// Mine exactly one block when ready
miner.start(1); admin.sleepBlocks(1); miner.stop()

// Alternative: start mining and stop manually for multiple transactions
miner.start(1)
// ... deploy contracts, send transactions ...
miner.stop()

// Check if mining is currently active
eth.mining

// Check current block number
eth.blockNumber

// See transaction count in mempool
eth.getBlockTransactionCount("pending")
```

## Adding Ports Later (When Needed)

The current setup only exposes SSH port (2222). When you need additional ports for blockchain connections, you can edit docker-compose.yml to add them and restart the container.

## Container Management
```bash
# Check if container is running (from host Mac terminal)
docker compose ps

# Stop container when done (Ctrl+C in terminal running docker compose up)

# View container logs if needed
docker compose logs -f

# Rebuild container if Dockerfile changes
docker compose build --no-cache

# Remove everything and start fresh
docker compose down
docker system prune -f
docker compose build --no-cache
```

**Note:** Container runs in foreground - keep the first terminal with `docker compose up` open, use other terminals to SSH in.

## Important Design Decisions & Context for Future LLM Conversations

### Why This Approach?
- **No Assumptions**: Start with minimal setup, add only what you need - User explicitly wants to install everything manually for learning
- **Learning Focused**: Install and configure everything manually to understand the process - Educational priority over convenience
- **Mac Compatible**: Uses `docker compose` (V2) syntax required for modern Mac Docker - User cannot use old docker-compose syntax
- **Container-Native**: Everything stays in container, no complex volume mounts - Simplicity over persistence
- **Flexible**: Easy to add ports, tools, or configurations later - Start minimal, expand as needed
- **Experimental**: Perfect for testing, breaking, and rebuilding without affecting host system
- **Simple Workflow**: Foreground container + new terminal for SSH (no background daemon management) - User preference for simplicity

### Critical Context for Future Conversations:
1. **User explicitly rejected `-d` flag** - wants foreground docker compose up, not background
2. **User is on Mac** - Docker Compose V2 syntax is mandatory
3. **User wants root SSH with no password** - simplicity over security for experimentation
4. **User wants manual installation of everything** - no pre-installed geth or tools
5. **Manual block creation is core requirement** - for precise smart contract testing workflow
6. **Data stays in container** - no host volume mounts for simplicity
7. **Ports added as needed** - start with just SSH, expand later

### Discussion Points That Were Resolved:
- Base image: Alpine chosen over Ubuntu/Debian for size
- SSH vs docker exec: SSH chosen for better terminal experience
- Geth installation: Manual installation preferred over pre-installation
- Container structure: Single service chosen over multi-service
- Development tools: Install as needed rather than pre-install
- Port exposure: Minimal initially, expand as required
- Data persistence: In-container storage chosen over host mounts
- Workflow: Foreground + new terminal chosen over background daemon

### Future Expansion Options:
- Add more ports in docker-compose.yml for external tool connections
- Install Node.js/npm for web3.js or ethers.js smart contract interaction
- Add Solidity compiler for smart contract development
- Set up multi-node networks by creating additional containers
- Connect external tools like Remix IDE or MetaMask to your blockchain
- Install development frameworks like Truffle, Hardhat, or Foundry

This setup provides a solid foundation that can grow with blockchain experimentation needs while maintaining the core philosophy of manual control and learning-first approach.