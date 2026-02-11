// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.19;

/**
 * @title IBAP578
 * @dev BAP-578 Non-Fungible Agent Standard Interface
 * Reference: https://github.com/bnb-chain/BEPs/blob/master/BAPs/BAP-578.md
 */
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

    struct AgentMetadata {
        string persona;
        string experience;
        string voiceHash;
        string animationURI;
        string vaultURI;
        bytes32 vaultHash;
    }
    
    struct LearningConfig {
        bytes32 learningRoot;
        bytes32 learningModel;
        AgentType agentType;
        bool crossChainEnabled;
    }
    
    // Standard BAP-578 Events
    event ActionExecuted(
        address indexed agentContract,
        uint256 indexed tokenId,
        bytes32 indexed requestId,
        bytes data,
        uint256 timestamp
    );
    
    event AgentFunded(
        uint256 indexed tokenId,
        address indexed funder,
        uint256 amount,
        uint256 newBalance
    );
    
    event LogicUpdated(
        uint256 indexed tokenId,
        address indexed oldLogic,
        address indexed newLogic
    );
    
    event LearningUpdated(
        uint256 indexed tokenId,
        bytes32 newRoot,
        bytes32 newModel,
        AgentType agentType
    );
    
    // Core Functions (Standard BAP-578)
    function executeAction(uint256 tokenId, bytes calldata data) external returns (bool);
    function setLogicAddress(uint256 tokenId, address newLogic) external;
    function fundAgent(uint256 tokenId) external payable;
    function withdrawBalance(uint256 tokenId, uint256 amount) external;
    
    // Query Functions
    function getState(uint256 tokenId) external view returns (State memory);
    function getAgentMetadata(uint256 tokenId) external view returns (AgentMetadata memory);
    function getLearningConfig(uint256 tokenId) external view returns (LearningConfig memory);
    function verifyLearning(uint256 tokenId, bytes32 leaf, bytes32[] calldata proof) external view returns (bool);
    
    // Standard ERC-721 Functions (inherited)
    function ownerOf(uint256 tokenId) external view returns (address);
    function balanceOf(address owner) external view returns (uint256);
}
