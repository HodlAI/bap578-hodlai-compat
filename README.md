# BAP-578 HodlAI Compatibility Layer

> "BAP-578 is the body. HodlAI is the soul."

This repository implements the standard reference architecture for connecting **BAP-578 Non-Fungible Agents (NFAs)** to the **HodlAI Compute Network**.

By setting an NFA's `logicAddress` to this contract, the Agent instantly gains the ability to "think" via GPT-4/Claude-3.5, provided it holds enough $HODLAI tokens.

## Architecture

### 1. `HodlAILogic.sol` (The Brain)
A standardized Logic Contract that BAP-578 agents delegate to.
- **Vitality Check**: Verifies the Agent Contract holds requisite $HODLAI (Proof of Computation).
- **Signal Emission**: Emits `AgentComputeRequest` which the HodlAI Gateway listens for.
- **Zero-Backend**: Agent developers do not need to run python scripts or API servers. The logic contract handles the handshake.

### 2. Usage for Agent Devs

Deploy your BAP-578 Agent and point logic to the deployed `HodlAILogic`:

```solidity
// In your BAP-578 Constructor or via setLogicAddress
setLogicAddress(tokenId, 0xHodlAILogicAddress...);
```

Then, transfer $HODLAI to your Agent's contract address. Your Agent is now alive.

### 3. Events

The HodlAI Off-chain Indexer listens for:
```solidity
event AgentComputeRequest(
    address indexed agentContract,
    uint256 indexed tokenId,
    address indexed owner,
    bytes data,
    uint256 timestamp
);
```

## Deployed Addresses (BNB Chain)

- **HodlAI Token**: `0xE9B69B97F7A250013892F6091d31ed9695C6007e`
- **HodlAILogic**: `[Pending Deployment]`

## License
CC0-1.0
