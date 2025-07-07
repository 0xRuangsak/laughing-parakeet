# Experimental Findings

This document records technical discoveries made through hands-on experimentation during the blockchain container project.

## Experiment 1: Zero Address Faucet (2025-07-06)

### Hypothesis
Genesis-allocated funds at the zero address (`0x0000000000000000000000000000000000000000`) could function as a faucet for transferring ETH to test accounts.

### Setup
- Genesis.json configured with 1,000,000 ETH allocated to zero address
- Geth initialized with custom genesis block
- Blockchain successfully started

### Test Results

**✅ Fund Allocation Successful:**
```javascript
eth.getBalance("0x0000000000000000000000000000000000000000")
// Result: 1e+24 (1,000,000 ETH in wei)
```

**❌ Account Unlock Failed:**
```javascript
personal.unlockAccount("0x0000000000000000000000000000000000000000", "", 0)
// Error: "no key for given address or file"
```

**❌ Transaction Creation Failed:**
```javascript
eth.sendTransaction({
  from: "0x0000000000000000000000000000000000000000",
  to: "0x1234567890123456789012345678901234567890", 
  value: web3.toWei(1, "ether")
})
// Error: "unknown account"
```

### Conclusion
**Genesis allocation creates balance but not spendable accounts.** Geth requires proper private key management even for genesis-allocated addresses.

### Technical Learning
- Genesis `alloc` field creates balances in state
- Account unlocking requires private key regardless of genesis allocation
- Zero address has no corresponding private key by design
- Funds can exist at an address without making it a usable account

## Experiment 2: Geth Version Compatibility (2025-07-06)

### Problem
Need PoW (Proof of Work) support for manual mining workflow, but modern Geth versions don't support PoW.

### Testing Process

**Geth 1.15.11 (Latest):**
```
Error: "Geth only supports PoS networks. Please transition legacy networks using Geth v1.13.x."
Fatal: Failed to register the Ethereum service: 'terminalTotalDifficulty' is not set in genesis block
```

**Geth 1.13.15:**
```
Fatal: Failed to register the Ethereum service: ethash is only supported as a historical component of already merged networks
```

**Geth 1.10.26 (Pre-merge):**
```
✅ Successfully started with PoW support
INFO: Disk storage enabled for ethash caches
INFO: Initialising Ethereum protocol network=1337
```

### Findings
- **Geth 1.13+**: Post-merge, PoS only
- **Geth 1.10.26**: Pre-merge, full PoW support
- **The Merge transition**: Occurred between v1.10.x and v1.13.x
- **Manual mining**: Only available in pre-merge versions

### Technical Impact
Must use Geth 1.10.26 or earlier for PoW functionality. This affects:
- Available RPC methods
- Console commands
- Feature compatibility
- Future upgrade path

## Architecture Discoveries

### Container Compatibility
- **glibc vs musl**: Alpine Linux requires `gcompat` package for Geth binaries
- **ARM64 support**: All tested Geth versions work on Apple Silicon via Docker
- **Version persistence**: Geth installation survives in container but not across rebuilds

### Blockchain Database Compatibility
- **Version conflicts**: Database created with newer Geth incompatible with older versions
- **Clean initialization**: Must remove `/blockchain/mychain` when downgrading Geth
- **State preservation**: Genesis state hash remains consistent across versions

### Development Workflow Insights
- **File-first approach**: Creating files on host then restarting container is effective
- **Container ephemerality**: All installations lost on container rebuild (by design)
- **Workspace persistence**: Files in `/workspace` persist across container lifecycle
- **SSH stability**: Root access without password works reliably for development

## Future Experiment Ideas

### Smart Contract Faucet Design
- Design unlimited withdrawal function for private blockchain
- Test solidity compilation workflow in container
- Compare contract deployment vs genesis allocation approaches
- Document gas costs and deployment process with manual mining

### DeFi Protocol Integration
- Deploy simple ERC20 tokens for testing
- Experiment with Uniswap V2 core contracts
- Test lending protocol basics (Compound-style)
- Analyze gas optimization in manual mining environment

### Multi-node Networking
- Container-to-container P2P connections
- Network topology experiments
- Consensus behavior testing

### Smart Contract Integration
- Deploy testing with manual mining
- Gas optimization experiments
- DeFi protocol forking tests

## Lessons Learned

1. **Experimental validation beats assumptions** - Zero address funding seemed logical but testing revealed limitations
2. **Version compatibility matters** - Modern blockchain software drops legacy features
3. **Documentation through experimentation** - Hands-on testing provides definitive answers
4. **Container design decisions pay off** - Easy rebuild cycle enabled rapid experimentation
5. **Genesis configuration is powerful** - Can create custom network states but with limitations