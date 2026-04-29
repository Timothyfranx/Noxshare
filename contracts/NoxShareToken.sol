// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Nox, euint256, externalEuint256} from "@iexec-nox/nox-protocol-contracts/contracts/sdk/Nox.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title NoxShareToken
 * @dev Minimal confidential token using raw euint256 mappings from the Nox SDK.
 */
contract NoxShareToken is Ownable {
    string public constant name = "NoxShare Palm Grove";
    string public constant symbol = "NOXPG";
    uint8 public constant decimals = 6;

    // Mapping from account to their encrypted balance handle (bytes32)
    mapping(address => bytes32) private _balances;

    event Transfer(address indexed from, address indexed to, bytes32 amountHandle);

    constructor() Ownable(msg.sender) {}

    /**
     * @dev Mints confidential tokens to an account.
     */
    function mint(address to, externalEuint256 amount, bytes calldata proof) external onlyOwner {
        euint256 amountHandle = Nox.fromExternal(amount, proof);
        euint256 currentBalance = euint256.wrap(_balances[to]);
        
        _balances[to] = euint256.unwrap(Nox.add(currentBalance, amountHandle));
        
        emit Transfer(address(0), to, _balances[to]);
    }

    /**
     * @dev Transfers confidential tokens.
     */
    function transfer(address to, externalEuint256 amount, bytes calldata proof) external {
        euint256 amountHandle = Nox.fromExternal(amount, proof);
        euint256 senderBalance = euint256.wrap(_balances[msg.sender]);
        
        // Subtract from sender (Reverts if insufficient funds inside Nox.sub)
        _balances[msg.sender] = euint256.unwrap(Nox.sub(senderBalance, amountHandle));
        
        // Add to recipient
        euint256 recipientBalance = euint256.wrap(_balances[to]);
        _balances[to] = euint256.unwrap(Nox.add(recipientBalance, amountHandle));
        
        emit Transfer(msg.sender, to, euint256.unwrap(amountHandle));
    }

    /**
     * @dev Returns the encrypted balance handle for an account.
     */
    function balanceOf(address account) external view returns (bytes32) {
        return _balances[account];
    }
}
