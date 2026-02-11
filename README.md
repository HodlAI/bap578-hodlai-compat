# BAP-578 HodlAI Compatibility Layer

> "BAP-578 is the body. HodlAI is the soul."

This repository implements the standard reference architecture for connecting **BAP-578 Non-Fungible Agents (NFAs)** to the **HodlAI Compute Network**.

By setting an NFA's `logicAddress` to this contract, the Agent instantly gains the ability to "think" via GPT-4/Claude-3.5, provided it holds enough $HODLAI tokens.

---

## Overview

[BAP-578](https://github.com/bnb-chain/BEPs/blob/master/BAPs/BAP-578.md) is the official BNB Chain standard for Non-Fungible Agents (NFAs). This compatibility layer enables BAP-578 agents to seamlessly access HodlAI's compute network without backend infrastructure.

### Key Features

- **BAP-578 Native**: Implements standard `executeAction` interface
- **Dynamic Quota**: $10 USD held = $1/day API quota (auto-adjusts with token price)
- **Gateway Callbacks**: Off-chain AI results written back on-chain
- **Zero-Backend**: Pure smart contract integration

---

## Architecture

### 1. `HodlAILogic.sol` (The Brain)

A standardized Logic Contract that BAP-578 agents delegate to.

| Feature | Description |
|---------|-------------|
| **Vitality Check** | Verifies Agent holds sufficient $HODLAI based on dynamic quota formula |
| **Rate Limiting** | Credits per hour calculated from token holdings |
| **Gateway Integration** | `onActionExecuted` callback for AI results |
| **Request Tracking** | Keccak256 request IDs with pending status |

```solidity
// Core entry point - BAP-578 standard
function executeAction(uint256 tokenId, bytes calldata data) external;

// Gateway callback with AI result
function onActionExecuted(
    address agentContract,
    uint256 tokenId,
    bytes32 requestId,
    bytes calldata result
) external onlyGateway;
```

### 2. Quota Calculation

HodlAI uses a dynamic credit system:

```
hourly_credits = (HODLAI_balance * credits_per_token_per_hour) / 1e18

Where credits_per_token_per_hour ≈ 0.000173 (at $0.0024/HODLAI)
Result: $10 held ≈ $1/day API quota
```

### 3. BAP-578 Ecosystem Integration

| Component | Address | Purpose |
|-----------|---------|---------|
| BAP-578 NFA Contract | `0xf2954d349D7FF9E0d4322d750c7c2921b0445fdf` | Standard NFA factory |
| ERC-8004 Registry | `0xBE6745f74DF1427a073154345040a37558059eBb` | Agent identity verification |
| NfaScan | [nfascan.io](https://github.com/Beehavedev/nfascan) | BAP-578 explorer |

---

## Quick Start for Agent Developers

### Step 1: Deploy or Use Existing BAP-578 Agent

```solidity
import "@bnb-chain/bap578/contracts/BAP578NFA.sol";

contract MyAgent is BAP578NFA {
    constructor() {
        // Your agent initialization
    }
}
```

### Step 2: Set HodlAILogic as Logic Address

```solidity
// In your agent setup or via governance
setLogicAddress(tokenId, 0xYourDeployedHodlAILogic);
```

### Step 3: Fund Agent with HODLAI

```solidity
// Transfer HODLAI to agent contract address
hodlaiToken.transfer(agentContractAddress, amount);
// Minimum: ~2500 HODLAI for basic compute access
```

### Step 4: Trigger AI Computation

```solidity
// Anyone can call - gas paid by caller
IBAP578(agentContract).executeAction(tokenId, abi.encode(
    "What is the optimal trading strategy for today's market?"
));
```

---

## Events

### Agent → Gateway (Request)
```solidity
event AgentComputeRequest(
    address indexed agentContract,
    uint256 indexed tokenId,
    address indexed owner,
    bytes data,
    uint256 estimatedCredits,
    uint256 timestamp
);
```

### Gateway → Chain (Response)
```solidity
event ActionExecuted(
    address indexed agentContract,
    uint256 indexed tokenId,
    bytes32 indexed requestId,
    bytes result
);
```

---

## Deployed Addresses

### BNB Chain Mainnet

| Contract | Address | Status |
|----------|---------|--------|
| **HodlAI Token** | `0x987e6269c6b7ea6898221882f11ea16f87b97777` | ✅ Live |
| **HodlAILogic** | `[Pending Deployment]` | ⏳ Awaiting deploy |
| **BAP-578 NFA** | `0xf2954d349D7FF9E0d4322d750c7c2921b0445fdf` | ✅ Live |
| **ERC-8004 Registry** | `0xBE6745f74DF1427a073154345040a37558059eBb` | ✅ Live |

---

## Technical Reference

### IBAP578 Interface

```solidity
interface IBAP578 {
    enum Status { Active, Paused, Terminated }
    enum AgentType { MerkleTree, LightMemory }
    
    struct State {
        uint256 balance;
        Status status;
        address owner;
        address logicAddress;
        uint256 lastActionTimestamp;
    }
    
    function executeAction(uint256 tokenId, bytes calldata data) external returns (bool);
    function setLogicAddress(uint256 tokenId, address newLogic) external;
    function getState(uint256 tokenId) external view returns (State memory);
    // ... (see interfaces/IBAP578.sol)
}
```

### Trust Score (NfaScan Integration)

Agents using HodlAILogic gain credibility points:

| Signal | Points |
|--------|--------|
| Verified source code | +30 |
| ERC-8004 identity registration | +25 |
| HodlAILogic integration | +20 |
| Merkle learning type | +20 |
| HODLAI balance > 2500 | +10 |

**Total possible**: 115/100 (High Trust: 70+)

---

## Resources

- **BAP-578 Spec**: [github.com/bnb-chain/BEPs/BAP-578.md](https://github.com/bnb-chain/BEPs/blob/master/BAPs/BAP-578.md)
- **Reference Implementation**: [ChatAndBuild/non-fungible-agents-BAP-578](https://github.com/ChatAndBuild/non-fungible-agents-BAP-578)
- **NfaScan Explorer**: [github.com/Beehavedev/nfascan](https://github.com/Beehavedev/nfascan)
- **HodlAI Gateway**: `https://gw.hodlai.fun`

---

## License

CC0-1.0 - Public domain. Use freely.

---

*Powered by HodlAI - Holding is Access*