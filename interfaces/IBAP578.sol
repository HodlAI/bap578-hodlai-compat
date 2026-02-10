// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.19;

/**
 * @title IBAP578
 * @dev Core BAP-578 Interface required for logic integration
 */
interface IBAP578 {
    enum Status { Active, Paused, Terminated }
    
    struct State {
        uint256 balance;
        Status status;
        address owner;
        address logicAddress;
        uint256 lastActionTimestamp;
    }

    struct AgentMetadata {
        string persona;       // JSON-encoded character traits
        string experience;        // Agent's role/purpose summary
        string voiceHash;     // Audio profile reference
        string animationURI;  // Animation/avatar URI
        string vaultURI;      // Extended data storage URI
        bytes32 vaultHash;    // Vault content verification hash
    }
    
    // Core Functions
    function executeAction(uint256 tokenId, bytes calldata data) external;
    function setLogicAddress(uint256 tokenId, address newLogic) external;
    function fundAgent(uint256 tokenId) external payable;
    function getState(uint256 tokenId) external view returns (State memory);
    function getAgentMetadata(uint256 tokenId) external view returns (AgentMetadata memory);
}
