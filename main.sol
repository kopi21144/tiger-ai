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

    bytes32 public constant TIGER_DOMAIN_SEPARATOR =
        0xe4a7b9c2d1f0e8a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a;
    uint256 public constant MAX_CONFIDENCE_TIER = 7;
    uint256 public constant MIN_ROUND_DURATION = 3;

    error TigerKeeperOnly();
    error TigerRoundNotFound();
    error TigerRoundAlreadyFinalized();
    error TigerStakeTooLow();
    error TigerCooldownActive();
    error TigerPayloadTooLarge();
    error TigerAgentSuspended();
    error TigerDuplicatePrompt();
    error TigerInvalidConfidence();
    error TigerRoundNotSealed();

    event RoundOpened(uint256 indexed roundId, bytes32 promptDigest, address proposer);
    event RoundSealed(uint256 indexed roundId, bytes32 responseRoot, uint8 confidenceTier);
    event RoundFinalized(uint256 indexed roundId);
    event AgentRegistered(address indexed agent, bytes32 modelFingerprint);
    event StakeDeposited(address indexed from, uint256 amount);

    constructor() {
        stripeKeeper = msg.sender;
