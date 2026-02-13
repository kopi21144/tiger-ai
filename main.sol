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

    struct InferenceRound {
        bytes32 promptDigest;
        bytes32 responseRoot;
        uint256 startedAt;
        uint256 sealedAt;
        bool finalized;
        uint8 confidenceTier;
        address proposer;
    }

    struct AgentSnapshot {
        bytes32 modelFingerprint;
        uint256 lastInferenceBlock;
        uint256 totalRounds;
        bool suspended;
    }

    mapping(uint256 => InferenceRound) private _rounds;
    mapping(address => AgentSnapshot) private _agents;
    mapping(bytes32 => uint256) private _promptToRound;
    uint256 private _roundCounter;
    uint256 private _totalStaked;

