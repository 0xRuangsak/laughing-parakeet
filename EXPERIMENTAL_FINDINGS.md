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

## Experiment 3: Solidity Compilation Issues (2025-07-06)

### Problem
Encountered compilation errors when trying to use decimal literals in Solidity contract convenience functions.

### Initial Issue
```solidity
function get001ETH() external {
    getETH(0.01 ether); // DeclarationError: Undeclared identifier
}
```

### Root Cause Analysis
The error "DeclarationError: Undeclared identifier" was misleading. The real issues were:

1. **Decimal Literals**: Solidity doesn't support decimal literals like `0.01 ether` or `0.1 ether`
2. **Mathematical Expressions**: Complex expressions like `0.01 * 1e18` can cause compilation issues
3. **Function Complexity**: Multiple convenience functions added unnecessary complexity

### Solution Applied
**Simplified Contract Design**: Removed all convenience functions and kept only core functionality:
- Single `getETH(uint256 amount)` function for custom amounts
- Users can specify exact wei amounts as needed
- Cleaner, more maintainable contract structure

### Technical Learning
- Solidity decimal literal limitations require explicit wei calculations
- Error messages can be misleading (showed "undeclared identifier" instead of "invalid literal")
- Simpler contract design often better than complex convenience functions
- Manual wei calculation gives more precise control

### Final Working Contract
```solidity
contract Faucet {
    function getETH(uint256 amount) external {
        require(address(this).balance >= amount, "Insufficient funds");
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }
    // ... other core functions
}
```

### Usage Examples
```javascript
// In geth console - specify amounts in wei
faucet.getETH(web3.toWei(0.01, "ether"))  // 0.01 ETH
faucet.getETH(web3.toWei(1, "ether"))     // 1 ETH  
faucet.getETH(web3.toWei(100, "ether"))   // 100 ETH
```

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

### Smart Contract Faucet Implementation
- Test solidity compilation workflow in container
- Deploy simplified faucet contract with manual mining
- Document gas costs and deployment process
- Compare contract vs genesis allocation approaches

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
6. **Solidity complexity vs simplicity** - Simple contract designs are more reliable and maintainable
7. **Error message interpretation** - Compiler errors can be misleading about actual issues