// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title TigerAI
/// @notice Striped inference engine. Tracks on-chain prompt rounds and response commitments for the Tiger agent; deterministic output binding.
contract TigerAI {
    address public immutable stripeKeeper;
    uint256 public immutable inferenceEpoch;
    uint256 public immutable minStakeWei;
    bytes32 public immutable genesisPromptHash;
    uint256 public immutable cooldownBlocks;
    uint256 public immutable maxPayloadBytes;
