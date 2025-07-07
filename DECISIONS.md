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
**Rationale**: User prefers creating files outside container, then using them inside clean environment
**Alternatives Considered**: 
- Direct file creation in container via SSH
- Real-time file sync during container operation
**Impact**: Workflow: create files on Mac → restart container → SSH to use files

### D013: Zero Address Faucet Experiment (2025-07-06)
**Decision**: Zero address funding approach does not work for faucet functionality
**Rationale**: Experimental testing proved that genesis-allocated funds at zero address cannot be transferred
**Alternatives Considered**: 
- Zero address with genesis allocation (tested - failed)
- Proper test address with known private key
- Smart contract faucet
**Impact**: Must use proper address with private key for faucet functionality

### D014: Geth Version for PoW Support (2025-07-06)
**Decision**: Use Geth 1.10.26 for Proof of Work mining capability
**Rationale**: Modern Geth versions (1.13+) only support PoS post-merge, need pre-merge version for PoW
**Alternatives Considered**: 
- Geth 1.15.11 (latest - PoS only)
- Geth 1.13.15 (post-merge - PoS only)
- Switch to PoS consensus (more complex setup)
**Impact**: Must use older Geth version, affects available features and future upgrade path

### D015: Smart Contract Faucet Architecture (2025-07-06)
**Decision**: Implement smart contract faucet with unlimited function for private blockchain
**Rationale**: User wants to learn smart contract development and deployment workflow
**Alternatives Considered**: 
- Genesis pre-funded address (too simple for learning goals)
- Remix IDE integration (external dependency)
- Hybrid approach (unnecessary complexity)
**Impact**: Requires Solidity compilation in container, contract deployment process, ABI handling

### D016: Solidity Development Toolchain (2025-07-06)
**Decision**: Use in-container Solidity compiler (Option A) over Remix IDE
**Rationale**: Aligns with file-first workflow, complete control, no external dependencies
**Alternatives Considered**: 
- Remix IDE (external tool, not fitting file-first workflow)
- Hybrid approach (compile in Remix, deploy in container)
**Impact**: Must install solc in container, manual ABI generation, complete compilation process learning

### D017: Faucet Contract Design (2025-07-06)
**Decision**: Unlimited faucet with custom amount function for private blockchain experimentation
**Rationale**: Private network allows unrestricted access, focus on learning over rate limiting
**Features Decided**:
- Custom amount withdrawal function: `getETH(uint256 amount)`
- No cooldowns, no limits, no tracking (private network)
- Contract refillable via direct ETH transfers
- Genesis allocation directly to contract address
**Impact**: Simple contract structure, focus on deployment/interaction learning

### D018: Simplified Faucet Contract Design (2025-07-06)
**Decision**: Remove convenience functions, use single getETH(uint256 amount) function only
**Rationale**: Compilation issues with decimal literals (0.01 ether) and complex convenience functions
**Problem Encountered**: 
- DeclarationError with decimal literals like `0.01 ether`
- Misleading error messages ("undeclared identifier" vs "invalid literal")
- Solidity doesn't support decimal expressions in function calls
**Solution Applied**: 
- Single main function: getETH(uint256 amount)
- Use web3.toWei() in geth console for user convenience
- Cleaner, more maintainable contract structure
**Impact**: Simpler compilation, easier debugging, web3-based user experience

### D019: File Update Protocol for Future LLMs (2025-07-06)
**Decision**: Mandatory requirement for future LLMs to provide complete files with filenames when making updates
**Rationale**: User explicitly required complete file visibility for proper workflow on Mac system
**Problem Encountered**: 
- LLM was using partial update syntax (artifacts.update with old_str/new_str)
- User could not see complete context or save files properly
- User stated: "when you need to update, you have to give me full file with with file name not like this!!!!!"
**Solution Applied**:
- MANDATORY: Always use complete file content with filename header
- Format: artifacts.create(title="FILENAME.ext - Complete Updated File", content="[ENTIRE FILE]")
- Apply to ALL file types: .md, .sol, .json, .sh, .yml, etc.
**Impact**: Future LLMs must always provide complete files, never partial updates, for user's Mac workflow

### D020: Pre-install Essential Blockchain Tools (2025-07-06)
**Decision**: Install Geth, Solidity compiler, and gcompat in Dockerfile instead of manual SSH installation
**Rationale**: These are foundational infrastructure tools, not experimental components
**Problem with Previous Approach**: 
- Geth installation is required infrastructure, not learning exercise
- SSH sessions spent on tool installation rather than blockchain experimentation
- Downloads and setup time detracted from learning focus
**Solution Applied**:
- Pre-install in Dockerfile: Geth 1.10.26, Solidity compiler, gcompat package
- SSH sessions focus on: blockchain initialization, contract deployment, experimentation
- Instant availability of all required tools
**Alternatives Considered**: 
- Keep manual installation (rejected - infrastructure not experiment)
- Install all development tools (rejected - still want some manual control)
**Impact**: Container build time increased but SSH sessions focused purely on blockchain learning

## User Preferences Established

### Technical Preferences
- Mac platform with Docker Compose V2 only
- Alpine Linux for minimal size
- Manual installation philosophy for learning (experimental tools only)
- Root access without authentication complexity
- Hybrid approach: workspace mount for dev files, container storage for blockchain data
- Pre-installed infrastructure tools (Geth, Solidity, gcompat)

### Workflow Preferences  
- Foreground container operation (no background daemon)
- SSH access from separate terminals
- Manual block creation for precise control
- Install-as-needed for experimental/advanced tools only
- Simple over complex solutions
- Fast editing on host, execution in container
- **File-first workflow**: Create files on Mac → restart container → SSH to use files
- **Complete file updates**: Must see entire file content, not partial updates
- **Infrastructure pre-installed**: Core tools available immediately

### Learning Philosophy
- Hands-on manual configuration for experimental aspects
- Understanding each step rather than black-box solutions
- Experimentation and iteration over production-ready setup
- Educational value prioritized over convenience
- Simpler designs preferred over complex convenience features
- Infrastructure tools pre-installed, experimental workflow manual

### Communication Preferences
- Complete file visibility when making updates
- Explicit filename headers for all file changes
- No partial updates or diff-style changes
- Full context required for proper Mac workflow

## Rejected Alternatives

### What Was NOT Chosen and Why
- **Ubuntu/Debian base**: Too large for user's preference
- **Background container (-d flag)**: User prefers foreground + new terminal workflow
- **Pre-installed geth**: User wants manual installation for learning (REVERSED in D020)
- **Full host volume mounts**: User prioritized simplicity, only workspace needed for dev files
- **Password/key SSH**: User wanted no authentication complexity
- **Automatic mining**: User needs manual control for smart contract testing
- **Pre-exposed ports**: User prefers minimal start, expand as needed
- **Docker exec access**: User specifically requested SSH capability
- **Single documentation file**: User agreed separate files better for organization
- **All-container editing**: Too slow for development workflow
- **Zero address faucet**: Experimental testing proved it doesn't work
- **Modern Geth versions**: Don't support PoW mining needed for manual control
- **Remix IDE compilation**: External dependency not fitting file-first workflow
- **Complex convenience functions**: Compilation issues with decimal literals, simpler is better
- **Partial file updates**: User requires complete file visibility with filenames
- **Manual tool installation**: Changed to pre-install for infrastructure tools (D020)