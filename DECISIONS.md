# Architecture and Design Decisions

This document records key decisions made during project development, including rationale and alternatives considered. Future LLMs should reference this to understand why specific choices were made.

## Decision Log

### D001: Platform and Tooling (2025-07-05)
**Decision**: Use Docker Compose V2 syntax (`docker compose`) on Mac
**Rationale**: User explicitly cannot run `docker-compose` (old syntax) and must use modern Docker Compose V2
**Alternatives Considered**: Native installation, other containerization tools
**Impact**: All documentation and scripts must use `docker compose` syntax

### D002: Base Container Image (2025-07-05)
**Decision**: Alpine Linux
**Rationale**: User prioritized lightweight, minimal footprint over familiarity
**Alternatives Considered**: 
- Ubuntu (familiar but larger ~70MB)
- Debian (middle ground ~50MB) 
- Official Ethereum/Geth image (less flexible)
**Impact**: Smaller container size, apk package manager, musl libc compatibility

### D003: Container Access Method (2025-07-05)
**Decision**: SSH as root with no password
**Rationale**: User wanted simplicity for experimentation, no security complexity needed
**Alternatives Considered**: 
- Docker exec (more Docker-native)
- SSH with password/keys
- Non-root user with sudo
**Impact**: Simple access but requires SSH setup in container

### D004: Container Workflow (2025-07-05)
**Decision**: Foreground container (`docker compose up`) + separate terminal for SSH
**Rationale**: User explicitly rejected background (-d) mode, prefers simple terminal management
**Alternatives Considered**: Background daemon with `docker compose up -d`
**Impact**: Must keep one terminal open with container running, SSH from other terminals

### D005: Pre-installation Philosophy (2025-07-05)
**Decision**: Install nothing pre-built, user installs everything manually
**Rationale**: User wants learning-focused approach, complete control over environment
**Alternatives Considered**: Pre-install geth, development tools, helper scripts
**Impact**: Clean minimal container, user must install geth and tools as needed

### D006: Data Persistence Strategy (2025-07-05)
**Decision**: Everything stays in container, no host volume mounts
**Rationale**: User prioritized simplicity over data persistence
**Alternatives Considered**: Mount host directories for blockchain data
**Impact**: Data lost when container is removed, but simpler setup

### D007: Network Port Exposure (2025-07-05)
**Decision**: Start with minimal ports (SSH only), add as needed
**Rationale**: Start simple, expand when specific needs arise
**Alternatives Considered**: Pre-expose all common geth ports
**Impact**: Must edit docker-compose.yml and restart container to add ports

### D008: Block Creation Strategy (2025-07-05)
**Decision**: Manual mining - blocks created only on command, not automatic
**Rationale**: Critical for smart contract testing workflow, precise transaction control needed
**Alternatives Considered**: Automatic mining with fixed intervals
**Impact**: Must manually mine blocks to process transactions, ideal for step-by-step experimentation

### D009: Smart Contract Development Approach (2025-07-05)
**Decision**: Install development tools as needed inside container
**Rationale**: User wants to experiment with installing tools, learn the process
**Alternatives Considered**: Pre-install Solidity compiler, Node.js, web3 libraries
**Impact**: User must manually install solc, npm packages, development frameworks when needed

### D010: Documentation Strategy (2025-07-05)
**Decision**: Separate DECISIONS.md and PROGRESS.md files
**Rationale**: Future LLMs need context since they can't see conversation history
**Alternatives Considered**: Single project log file, everything in README
**Impact**: Better organization of decisions vs timeline, easier for LLMs to understand context

### D011: Development Workflow Enhancement (2025-07-05)
**Decision**: Add workspace folder mount for development files
**Rationale**: SSH editing in container was very slow, needed fast development workflow
**Alternatives Considered**: 
- Continue with slow SSH editing
- Use docker exec instead of SSH
- Full host volume mount for all data
**Impact**: Development files edited on Mac in `./workspace`, mounted to `/workspace` in container

### D012: File-First Development Workflow (2025-07-06)
**Decision**: Create files on Mac first, then restart container to use them
**Rationale**: User prefers editing files outside container, then restarting for clean environment
**Alternatives Considered**: 
- Create files directly in container via SSH
- Edit files in container then sync to host
- Live editing with hot-reload
**Impact**: Development files created on Mac in workspace, container restarted to pick up changes

## User Preferences Established

### Technical Preferences
- Mac platform with Docker Compose V2 only
- Alpine Linux for minimal size
- Manual installation philosophy for learning
- Root access without authentication complexity
- Hybrid approach: workspace mount for dev files, container storage for blockchain data

### Workflow Preferences  
- Foreground container operation (no background daemon)
- SSH access from separate terminals
- Manual block creation for precise control
- Install-as-needed for development tools
- Simple over complex solutions
- Fast editing on host, execution in container
- **File-first workflow**: Create files on Mac → restart container → SSH to use files

### Learning Philosophy
- Hands-on manual configuration over automation
- Understanding each step rather than black-box solutions
- Experimentation and iteration over production-ready setup
- Educational value prioritized over convenience

## Rejected Alternatives

### What Was NOT Chosen and Why
- **Ubuntu/Debian base**: Too large for user's preference
- **Background container (-d flag)**: User prefers foreground + new terminal workflow
- **Pre-installed geth**: User wants manual installation for learning
- **Full host volume mounts**: User prioritized simplicity, only workspace needed for dev files
- **Password/key SSH**: User wanted no authentication complexity
- **Automatic mining**: User needs manual control for smart contract testing
- **Pre-exposed ports**: User prefers minimal start, expand as needed
- **Docker exec access**: User specifically requested SSH capability
- **Single documentation file**: User agreed separate files better for organization
- **All-container editing**: Too slow for development workflow