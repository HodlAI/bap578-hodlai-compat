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
    // HODLAI Token (BSC Mainnet)
    address public constant HODLAI_TOKEN = 0x987e6269c6b7ea6898221882f11ea16f87b97777;
    
    // HodlAI Gateway (off-chain compute coordinator)
    address public gateway;
    
    // Rate: $10 held = $1/day quota = ~416 credits/hour (at $0.0024/HODLAI)
    // Credits per token per hour (scaled by 1e18)
    uint256 public creditsPerTokenPerHour = 173 * 10**12; // ~0.000173 credits per token per hour
    
    // Events - The bridge between Chain and AI
    event AgentComputeRequest(
        address indexed agentContract,
        uint256 indexed tokenId,
        address indexed owner,
        bytes data,
        uint256 estimatedCredits,
        uint256 timestamp
    );
    
    event ActionExecuted(
        address indexed agentContract,
        uint256 indexed tokenId,
        bytes32 indexed requestId,
        bytes result
    );

    event LogicConfigUpdated(uint256 newCreditsRate);

    address public owner;
    
    // Request tracking
    mapping(bytes32 => bool) public pendingRequests;

    modifier onlyGateway() {
        require(msg.sender == gateway, "HodlAILogic: Only gateway");
        _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "HodlAILogic: Only owner");
        _;
    }

    constructor(address _gateway) {
        owner = msg.sender;
        gateway = _gateway;
    }

    /**
     * @notice BAP-578 Standard Entry Point
     * @param tokenId The NFA token ID
     * @param data The input data/prompt for the AI
     * @dev Called by IBAP578.executeAction -> delegates to logicAddress
     */
    function executeAction(uint256 tokenId, bytes calldata data) external {
        // Caller is the BAP-578 NFA contract
        IBAP578 agent = IBAP578(msg.sender);
        IBAP578.State memory state = agent.getState(tokenId);
        
        // Verify the logic is set to this contract
        require(state.logicAddress == address(this), "HodlAILogic: Logic not active");
        
        // Check Agent status
        require(state.status == IBAP578.Status.Active, "HodlAILogic: Agent not active");
        
        // Calculate available quota based on HODLAI holdings
        uint256 agentBalance = IERC20(HODLAI_TOKEN).balanceOf(msg.sender);
        uint256 hourlyCredits = (agentBalance * creditsPerTokenPerHour) / 1e18;
        require(hourlyCredits > 0, "HodlAILogic: Insufficient HODLAI for compute");

        // Generate request ID
        bytes32 requestId = keccak256(abi.encodePacked(
            msg.sender,
            tokenId,
            data,
            block.timestamp,
            block.number
        ));
        pendingRequests[requestId] = true;

        // Emit Signal to Off-chain Compute Network
        emit AgentComputeRequest(
            msg.sender,
            tokenId,
            state.owner,
            data,
            hourlyCredits,
            block.timestamp
        );
    }
    
    /**
     * @notice Gateway callback with AI computation result
     * @param agentContract The BAP-578 agent contract address
     * @param tokenId The NFA token ID
     * @param requestId The request identifier
     * @param result The AI computation result
     */
    function onActionExecuted(
        address agentContract,
        uint256 tokenId,
        bytes32 requestId,
        bytes calldata result
    ) external onlyGateway {
        require(pendingRequests[requestId], "HodlAILogic: Invalid request");
        delete pendingRequests[requestId];
        
        emit ActionExecuted(agentContract, tokenId, requestId, result);
    }
    
    /**
     * @notice Calculate available credits for an agent
     * @param agentContract The agent contract address
     */
    function getAvailableCredits(address agentContract) external view returns (uint256) {
        uint256 balance = IERC20(HODLAI_TOKEN).balanceOf(agentContract);
        return (balance * creditsPerTokenPerHour) / 1e18;
    }

    function setCreditsRate(uint256 _creditsPerTokenPerHour) external onlyOwner {
        creditsPerTokenPerHour = _creditsPerTokenPerHour;
        emit LogicConfigUpdated(_creditsPerTokenPerHour);
    }
    
    function setGateway(address _gateway) external onlyOwner {
        gateway = _gateway;
    }
}
