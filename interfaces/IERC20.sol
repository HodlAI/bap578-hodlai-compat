// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title IERC20
 * @dev Interface for the HODLAI Token
 */
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}
