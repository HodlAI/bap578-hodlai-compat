// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interfaces/IBAP578.sol";
import "../interfaces/IERC20.sol";

/**
 * @title HodlAILogic
 * @author HodlAI Team
 * @notice The "Brain" of a BAP-578 Agent. Connects NFA actors to the HodlAI Compute Network.
 * @dev Implements a logic provider that gates execution based on HODLAI holdings.
 */
contract HodlAILogic {
    // Check HODLAI Balance (BSC Contract)
    address public constant HODLAI_TOKEN = 0xE9B69B97F7A250013892F6091d31ed9695C6007e; 
    
    // Minimum holding required to access Compute (e.g., $10 worth approx 2500 HODLAI at $0.004)
    // This can be made dynamic via Oracle in V2. Fixed for MVP.
    uint256 public minHoldingRequired = 2500 * 10**18;
    
    // Events - The bridge between Chain and AI
    event AgentComputeRequest(
        address indexed agentContract,
        uint256 indexed tokenId,
        address indexed owner,
        bytes data,
        uint256 timestamp
    );

    event LogicConfigUpdated(uint256 newMinHolding);

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    /**
     * @notice The core entry point for BAP-578 Agents.
     * @param data The input data/prompt for the AI.
     * @dev This function is delegatecalled by the Agent, or called directly with agent context.
     * BAP-578 spec implies `executeAction` calls implementation. 
     * If using DelegateCall in Agent: msg.sender is User, address(this) is Agent.
     * If using Call: msg.sender is Agent.
     * Assuming standard Logic implementation where Agent calls this.
     */
    function execute(uint256 tokenId, bytes calldata data) external {
        // 1. Identify the Agent (Caller is the NFA Contract)
        address agentContract = msg.sender;
        
        // 2. Verify Vitality (HODLAI Balance)
        // The Agent Contract itself must hold the tokens to have "Life".
        uint256 agentBalance = IERC20(HODLAI_TOKEN).balanceOf(agentContract);
        require(agentBalance >= minHoldingRequired, "HodlAILogic: Insufficient Vitality (HODLAI) to think.");

        // 3. fetch State (Optional validation)
        // IBAP578(agentContract).getState(tokenId);

        // 4. Emit Signal to Off-chain Compute Network
        // HodlAI Gateway indices this event -> Runs LLM -> Callbacks or Posts result
        emit AgentComputeRequest(
            agentContract,
            tokenId,
            tx.origin, // The user triggering the thought
            data,
            block.timestamp
        );
    }

    function setMinHolding(uint256 _amount) external onlyOwner {
        minHoldingRequired = _amount;
        emit LogicConfigUpdated(_amount);
    }
}
