// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Nox, euint256, externalEuint256, ebool} from "@iexec-nox/nox-protocol-contracts/contracts/sdk/Nox.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface INoxShareToken {
    function mintWithHandle(address to, bytes32 handle) external;
    function balanceOf(address account) external view returns (bytes32);
}

/**
 * @title NoxShare
 * @dev Consolidated contract for fractional land ownership and private yield distribution.
 * Integrates with iExec Nox for on-chain privacy and iExec TEE for off-chain calculation.
 */
contract NoxShare is Ownable {
    
    // iExec PoCo address on Arbitrum Sepolia
    address public constant IEXEC_POCO = 0xB2157BF2fAb286b2A4170E3491Ac39770111Da3E;

    // Total supply of micro-shares (1,000,000 = 100.0000%)
    uint256 public constant TOTAL_SHARES = 1000000;

    // The confidential token representing shares
    INoxShareToken public shareToken;
    
    // Result of the latest TEE calculation (stored as handle)
    mapping(address => bytes32) private _pendingDividends;

    // ─── AUCTION STORAGE ─────────────────────────────────────────
    struct Auction {
        uint256 endTime;
        address highestBidder;
        euint256 highestBid;
        bool settled;
    }

    Auction public currentAuction;

    event ShareMinted(address indexed investor, bytes32 handle);
    event YieldCycleRequested(uint256 revenueAmount, uint256 cycleId);
    event ResultReceived(address indexed investor, bytes32 dividendHandle);
    event AuctionStarted(uint256 endTime);
    event BidSubmitted(address indexed bidder, uint256 timestamp);
    event AuctionSettled(address indexed winner);

    modifier onlyIExec() {
        require(msg.sender == IEXEC_POCO, "Unauthorized: Only iExec PoCo can call");
        _;
    }

    constructor(address _shareToken) Ownable(msg.sender) {
        shareToken = INoxShareToken(_shareToken);
    }

    /**
     * @dev Mints shares to an investor via the shareToken.
     * The main contract validates the input and then passes the handle to the token contract.
     */
    function mintShare(address investor, externalEuint256 encryptedAmount, bytes calldata proof) public onlyOwner {
        // 1. Validate and wrap the external input
        // Since Wallet calls this, owner in proof must be Wallet, and app in proof must be NoxShare
        euint256 amountHandle = Nox.fromExternal(encryptedAmount, proof);
        
        // 2. Grant the shareToken contract permission to use this handle
        Nox.allow(amountHandle, address(shareToken));
        
        // 3. Call the token contract to perform the mint
        shareToken.mintWithHandle(investor, euint256.unwrap(amountHandle));
        
        bytes32 handle = shareToken.balanceOf(investor);
        emit ShareMinted(investor, handle);
    }

    // ─── START AUCTION ───────────────────────────────────────────
    function startAuction(uint256 durationSeconds) external onlyOwner {
        require(currentAuction.settled || currentAuction.endTime == 0, "Auction still active");
        currentAuction = Auction({
            endTime: block.timestamp + durationSeconds,
            highestBidder: address(0),
            highestBid: euint256.wrap(0),
            settled: false
        });
        emit AuctionStarted(currentAuction.endTime);
    }

    // ─── SUBMIT BID ──────────────────────────────────────────────
    function submitBid(
        externalEuint256 encryptedBid,
        bytes calldata proof
    ) external {
        require(block.timestamp < currentAuction.endTime, "Auction ended");
        require(!currentAuction.settled, "Already settled");

        euint256 newBid = Nox.fromExternal(encryptedBid, proof);

        // Encrypted comparison — no one sees the amounts
        ebool isHigher = Nox.gt(newBid, currentAuction.highestBid);

        // Conditionally update highest bid — stays encrypted
        currentAuction.highestBid = Nox.select(isHigher, newBid, currentAuction.highestBid);

        // Update winner address (Optimistic update as per plan)
        currentAuction.highestBidder = msg.sender;

        emit BidSubmitted(msg.sender, block.timestamp);
    }

    // ─── SETTLE AUCTION ──────────────────────────────────────────
    function settleAuction() external onlyOwner {
        require(block.timestamp >= currentAuction.endTime, "Not ended yet");
        require(!currentAuction.settled, "Already settled");
        require(currentAuction.highestBidder != address(0), "No bids received");

        currentAuction.settled = true;

        // Note: For the purpose of the demo, we emit the settled event.
        // In a production flow, we would mint the winning shares.
        emit AuctionSettled(currentAuction.highestBidder);
    }

    // ─── VIEW ────────────────────────────────────────────────────
    function getAuctionStatus() external view returns (
        uint256 endTime,
        address currentLeader,
        bool settled
    ) {
        return (
            currentAuction.endTime,
            currentAuction.highestBidder,
            currentAuction.settled
        );
    }

    /**
     * @dev Records that a yield cycle has been requested.
     * The actual TEE task is triggered from the frontend using the iExec SDK.
     */
    function requestYieldCycle(uint256 revenueAmount) external onlyOwner {
        uint256 cycleId = block.timestamp;
        emit YieldCycleRequested(revenueAmount, cycleId);
    }

    /**
     * @dev Callback for the TEE result.
     * Restricted to iExec PoCo to prevent fake dividend injection.
     */
    function receiveResult(address investor, bytes32 dividendHandle) external onlyIExec {
        _pendingDividends[investor] = dividendHandle;
        emit ResultReceived(investor, dividendHandle);
    }

    function getShareHandle(address investor) external view returns (bytes32) {
        return shareToken.balanceOf(investor);
    }

    function getDividendHandle(address investor) external view returns (bytes32) {
        return _pendingDividends[investor];
    }
}
