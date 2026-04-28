// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Nox, euint256, externalEuint256} from "@iexec-nox/nox-protocol-contracts/contracts/sdk/Nox.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title NoxShare
 * @dev Consolidated contract for fractional land ownership and private yield distribution.
 * Integrates with iExec Nox for on-chain privacy and iExec TEE for off-chain calculation.
 */
contract NoxShare is Ownable {
    
    // iExec PoCo address on Arbitrum Sepolia
    address public constant IEXEC_POCO = 0x3aEc1855869991b928113756E0586a5d7047bf18;

    // Total supply of micro-shares (1,000,000 = 100.0000%)
    uint256 public constant TOTAL_SHARES = 1000000;

    // Mapping from investor to their encrypted share handle (bytes32)
    mapping(address => bytes32) private _encryptedShares;
    
    // Result of the latest TEE calculation (stored as handle)
    mapping(address => bytes32) private _pendingDividends;

    event ShareMinted(address indexed investor, bytes32 handle);
    event YieldCycleRequested(uint256 revenueAmount, uint256 cycleId);
    event ResultReceived(address indexed investor, bytes32 dividendHandle);

    modifier onlyIExec() {
        require(msg.sender == IEXEC_POCO, "Unauthorized: Only iExec PoCo can call");
        _;
    }

    constructor() Ownable(msg.sender) {}

    /**
     * @dev Mints shares to an investor. The amount is passed as an encrypted handle.
     */
    function mintShare(address investor, externalEuint256 encryptedAmount, bytes calldata proof) external onlyOwner {
        euint256 amountHandle = Nox.fromExternal(encryptedAmount, proof);
        
        euint256 currentShares = euint256.wrap(_encryptedShares[investor]);
        _encryptedShares[investor] = euint256.unwrap(Nox.add(currentShares, amountHandle));
        
        emit ShareMinted(investor, _encryptedShares[investor]);
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
        return _encryptedShares[investor];
    }

    function getDividendHandle(address investor) external view returns (bytes32) {
        return _pendingDividends[investor];
    }
}
