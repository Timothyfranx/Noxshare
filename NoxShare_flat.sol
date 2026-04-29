◇ injected env (2) from .env // tip: ⌘ custom filepath { path: '/custom/path/.env' }
// Sources flattened with hardhat v3.4.1 https://hardhat.org

// SPDX-License-Identifier: MIT

// File npm/@iexec-nox/nox-protocol-contracts@0.2.2/contracts/shared/TypeUtils.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.27;

/**
 * @notice Enum values MUST NOT be reordered or removed once deployed.
 * New types should only be appended at the end to maintain backward compatibility.
 */
enum TEEType {
    // ============ Special Types (0-3) ============
    Bool, // 0
    Address, // 1
    Bytes, // 2 (dynamic)
    String, // 3
    // ============ Unsigned Integer Types (4-35) ============
    Uint8, // 4
    Uint16, // 5
    Uint24, // 6
    Uint32, // 7
    Uint40, // 8
    Uint48, // 9
    Uint56, // 10
    Uint64, // 11
    Uint72, // 12
    Uint80, // 13
    Uint88, // 14
    Uint96, // 15
    Uint104, // 16
    Uint112, // 17
    Uint120, // 18
    Uint128, // 19
    Uint136, // 20
    Uint144, // 21
    Uint152, // 22
    Uint160, // 23
    Uint168, // 24
    Uint176, // 25
    Uint184, // 26
    Uint192, // 27
    Uint200, // 28
    Uint208, // 29
    Uint216, // 30
    Uint224, // 31
    Uint232, // 32
    Uint240, // 33
    Uint248, // 34
    Uint256, // 35
    // ============ Signed Integer Types (36-67) ============
    Int8, // 36
    Int16, // 37
    Int24, // 38
    Int32, // 39
    Int40, // 40
    Int48, // 41
    Int56, // 42
    Int64, // 43
    Int72, // 44
    Int80, // 45
    Int88, // 46
    Int96, // 47
    Int104, // 48
    Int112, // 49
    Int120, // 50
    Int128, // 51
    Int136, // 52
    Int144, // 53
    Int152, // 54
    Int160, // 55
    Int168, // 56
    Int176, // 57
    Int184, // 58
    Int192, // 59
    Int200, // 60
    Int208, // 61
    Int216, // 62
    Int224, // 63
    Int232, // 64
    Int240, // 65
    Int248, // 66
    Int256, // 67
    // ============ Fixed-size Bytes Types (68-99) ============
    Bytes1, // 68
    Bytes2, // 69
    Bytes3, // 70
    Bytes4, // 71
    Bytes5, // 72
    Bytes6, // 73
    Bytes7, // 74
    Bytes8, // 75
    Bytes9, // 76
    Bytes10, // 77
    Bytes11, // 78
    Bytes12, // 79
    Bytes13, // 80
    Bytes14, // 81
    Bytes15, // 82
    Bytes16, // 83
    Bytes17, // 84
    Bytes18, // 85
    Bytes19, // 86
    Bytes20, // 87
    Bytes21, // 88
    Bytes22, // 89
    Bytes23, // 90
    Bytes24, // 91
    Bytes25, // 92
    Bytes26, // 93
    Bytes27, // 94
    Bytes28, // 95
    Bytes29, // 96
    Bytes30, // 97
    Bytes31, // 98
    Bytes32 // 99
}

error NonArithmeticType();
error UnsupportedArithmeticType();

library TypeUtils {
    /**
     * Returns the list of all currently supported TEE types.
     * @dev Update this list when new types are supported.
     */
    function allCurrentlySupportedTypes() internal pure returns (TEEType[] memory types) {
        types = new TEEType[](5);
        types[0] = TEEType.Bool;
        types[1] = TEEType.Uint16;
        types[2] = TEEType.Uint256;
        types[3] = TEEType.Int16;
        types[4] = TEEType.Int256;
    }

    /**
     * @notice Extracts the TEE type from a handle.
     * The type is stored at byte position 5 in the handle.
     * @param handle The handle to extract the type from
     * @return The TEEType encoded in the handle
     */
    function typeOf(bytes32 handle) internal pure returns (TEEType) {
        return TEEType(uint8(handle[5]));
    }

    /**
     * @notice Validates that a TEE type is supported for arithmetic operations.
     * Only the following arithmetic types are supported:
     *  - uint16
     *  - uint256
     *  - int16
     *  - int256
     * @param teeType The TEE type to validate
     * @dev Reverts with NonArithmeticType when the type is not an arithmetic type.
     * @dev Reverts with UnsupportedArithmeticType when the type is not supported.
     */
    function validateArithmeticType(TEEType teeType) internal pure {
        uint8 t = uint8(teeType);
        require(t >= uint8(TEEType.Uint8) && t <= uint8(TEEType.Int256), NonArithmeticType());
        bool supportedType =
            teeType == TEEType.Uint16 ||
                teeType == TEEType.Uint256 ||
                teeType == TEEType.Int16 ||
                teeType == TEEType.Int256;
        require(supportedType, UnsupportedArithmeticType());
    }
}


// File npm/@iexec-nox/nox-protocol-contracts@0.2.2/contracts/interfaces/INoxCompute.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.27;

/**
 * @title INoxCompute
 * @notice Interface for the Nox compute contract powered by TEE.
 */
interface INoxCompute {
    /// Error thrown when account address is zero
    error InvalidZeroAddress();
    /// Error thrown when bytes parameter is empty
    error InvalidEmptyBytes();
    /// Error thrown when sender doesn't have access to the handle
    error UnauthorizedSender(address sender);
    /// Error thrown when an account is not allowed to use a handle
    error NotAllowed(bytes32 handle, address account);
    error InvalidProof(bytes proof, string reason);
    error UnsupportedType();
    error IncompatibleTypes();
    error NotPubliclyDecryptable(bytes32 handle);
    /// Error thrown when attempting an ACL mutation on a public handle
    error PublicHandleACLForbidden();
    /// Error thrown when an operand is bytes32(0), indicating an undefined handle
    error UndefinedHandle();

    /// Emitted when admin role is granted
    event Allowed(address indexed sender, address indexed account, bytes32 indexed handle);
    /// Emitted when viewer role is granted
    event ViewerAdded(address indexed sender, address indexed viewer, bytes32 indexed handle);
    /// Emitted when a handle is marked as publicly decryptable
    event MarkedAsPubliclyDecryptable(address indexed sender, bytes32 indexed handle);
    event KmsPublicKeyUpdated(bytes newKmsPublicKey);
    event GatewayUpdated(address indexed newGateway);
    event ProofExpirationDurationUpdated(uint256 newDuration);

    event WrapAsPublicHandle(
        address indexed caller,
        bytes32 plaintext,
        TEEType toType,
        bytes32 result
    );
    event Add(
        address indexed caller,
        bytes32 leftHandOperand,
        bytes32 rightHandOperand,
        bytes32 result
    );
    event Sub(
        address indexed caller,
        bytes32 leftHandOperand,
        bytes32 rightHandOperand,
        bytes32 result
    );
    event Div(
        address indexed caller,
        bytes32 leftHandOperand,
        bytes32 rightHandOperand,
        bytes32 result
    );
    event Mul(
        address indexed caller,
        bytes32 leftHandOperand,
        bytes32 rightHandOperand,
        bytes32 result
    );
    event Eq(
        address indexed caller,
        bytes32 leftHandOperand,
        bytes32 rightHandOperand,
        bytes32 result
    );
    event Ne(
        address indexed caller,
        bytes32 leftHandOperand,
        bytes32 rightHandOperand,
        bytes32 result
    );
    event Lt(
        address indexed caller,
        bytes32 leftHandOperand,
        bytes32 rightHandOperand,
        bytes32 result
    );
    event Le(
        address indexed caller,
        bytes32 leftHandOperand,
        bytes32 rightHandOperand,
        bytes32 result
    );
    event Gt(
        address indexed caller,
        bytes32 leftHandOperand,
        bytes32 rightHandOperand,
        bytes32 result
    );
    event Ge(
        address indexed caller,
        bytes32 leftHandOperand,
        bytes32 rightHandOperand,
        bytes32 result
    );
    event SafeAdd(
        address indexed caller,
        bytes32 leftHandOperand,
        bytes32 rightHandOperand,
        bytes32 success,
        bytes32 result
    );
    event SafeSub(
        address indexed caller,
        bytes32 leftHandOperand,
        bytes32 rightHandOperand,
        bytes32 success,
        bytes32 result
    );
    event SafeMul(
        address indexed caller,
        bytes32 leftHandOperand,
        bytes32 rightHandOperand,
        bytes32 success,
        bytes32 result
    );
    event SafeDiv(
        address indexed caller,
        bytes32 numerator,
        bytes32 denominator,
        bytes32 success,
        bytes32 result
    );
    event Select(
        address indexed caller,
        bytes32 condition,
        bytes32 ifTrue,
        bytes32 ifFalse,
        bytes32 result
    );
    event Transfer(
        address indexed caller,
        bytes32 balanceFrom,
        bytes32 balanceTo,
        bytes32 amount,
        bytes32 success,
        bytes32 newBalanceFrom,
        bytes32 newBalanceTo
    );
    event Mint(
        address indexed caller,
        bytes32 balanceTo,
        bytes32 amount,
        bytes32 totalSupply,
        bytes32 success,
        bytes32 newBalanceTo,
        bytes32 newTotalSupply
    );
    event Burn(
        address indexed caller,
        bytes32 balanceFrom,
        bytes32 amount,
        bytes32 totalSupply,
        bytes32 success,
        bytes32 newBalanceFrom,
        bytes32 newTotalSupply
    );

    enum Operator {
        WrapAsPublicHandle,
        Add,
        Sub,
        Mul,
        Div,
        SafeAdd,
        SafeSub,
        SafeMul,
        SafeDiv,
        Select,
        Eq,
        Ne,
        Lt,
        Le,
        Gt,
        Ge,
        Transfer,
        Mint,
        Burn
    }

    // ------------- ACL functions -------------

    /**
     * Grant admin role to another address for a specific handle
     * @dev Caller must have access (transient OR persistent) to the handle
     * @param handle The handle identifier
     * @param account The address to grant admin role
     */
    function allow(bytes32 handle, address account) external;

    /**
     * Allows the use of `handle` by address `account` for this transaction.
     * @param handle Handle.
     * @param account Address of the account.
     */
    function allowTransient(bytes32 handle, address account) external;

    /**
     * Revokes transient access to `handle` for address `account` within the current transaction.
     * @param handle Handle.
     * @param account Address of the account.
     */
    function disallowTransient(bytes32 handle, address account) external;

    /**
     * Returns whether the account is allowed to use the `handle`, either due to
     * allowTransient() or allow().
     * @param handle Handle.
     * @param account Address of the account.
     * @return Whether the account can access the handle (persistent or transient).
     */
    function isAllowed(bytes32 handle, address account) external view returns (bool);

    /**
     * Checks whether the account is allowed to use all provided handles.
     * Reverts with NotAllowed if any handle is not allowed.
     * @param account Address of the account.
     * @param handles Array of handles to check.
     */
    function validateAllowedForAll(address account, bytes32[] calldata handles) external view;

    /**
     * Add a viewer for a specific handle
     * @dev Only an admin can add a viewer. The viewer address cannot be address(0).
     * @param handle The handle identifier
     * @param viewer The address to grant viewer role
     */
    function addViewer(bytes32 handle, address viewer) external;

    /**
     * Returns whether the account can view the handle.
     * @dev Returns true if any of the following conditions are met:
     *      - The handle is publicly decryptable
     *      - The account was added as a viewer via `addViewer`
     *      - The account has persistent access (is allowed) on the handle
     * @param handle Handle.
     * @param viewer Address of the viewer.
     * @return Whether the account can view the handle.
     */
    function isViewer(bytes32 handle, address viewer) external view returns (bool);

    /**
     * Mark a handle as publicly decryptable.
     * @dev The caller must be allowed to use the handle.
     *      If not, the function reverts.
     * @param handle Handle to mark as publicly decryptable.
     */
    function allowPublicDecryption(bytes32 handle) external;

    /**
     * Checks whether a handle is publicly decryptable.
     * @param handle Handle.
     * @return Whether the handle is publicly decryptable.
     */
    function isPubliclyDecryptable(bytes32 handle) external view returns (bool);

    // ------------- Compute functions -------------

    /**
     * @notice Wraps a plaintext value into a deterministic public handle.
     * The resulting handle has bit 0 of the attributes byte (byte 30) unset,
     * meaning it can be non unique, it carries no ACL and is accessible by everyone.
     * The same value and type always produce the same handle.
     * @param value The plaintext value
     * @param teeType The type of the handle
     * @return The public handle
     */
    function wrapAsPublicHandle(bytes32 value, TEEType teeType) external returns (bytes32);

    /**
     * Validates that a handle provided by a user is:
     *   - of expected type
     *   - not expired
     *   - issued for the correct app (caller)
     *   - issued for the correct owner
     *   - issued by the configured gateway (signed by the gateway wallet)
     * or reverts otherwise.
     *
     * Handle format:
     *  1 byte    4 bytes      1 byte  1 byte      25 bytes
     *   [0]     [1------4]     [5]     [6]     [7-----------31]
     * Version    ChainId       Type    Attrs      Pre-handle
     *
     * Proof format:
     *  20 bytes       20 bytes        32 bytes            65 bytes
     * [0-----19]    [20-----39]    [40--------71]    [72------------136]
     *   Owner           App           CreatedAt       EIP-712 signature
     *
     * @param handle handle id
     * @param owner The address of the handle owner
     * @param proof Proof data
     */
    function validateInputProof(
        bytes32 handle,
        address owner,
        bytes calldata proof,
        TEEType teeType
    ) external;

    /**
     * Validates the decryption proof issued by the gateway for a given handle.
     * The proof must be signed by the configured gateway.
     *
     * The proof uses a compact serialization: `signature (65 bytes) || decryptedResult (N bytes)`.
     * The signature is placed first (fixed size) so that `decryptedResult` can be variable-length,
     * supporting all current and future types that may exceed 32 bytes (e.g. encrypted strings).
     *
     * @param handle Handle to decrypt
     * @param decryptionProof Compact proof: `signature (65 bytes) || decryptedResult (N bytes)`
     * @return decryptedResult The decrypted value extracted from the proof if the proof is valid,
     * or reverts otherwise
     */
    function validateDecryptionProof(
        bytes32 handle,
        bytes calldata decryptionProof
    ) external view returns (bytes memory);

    /**
     * @notice Performs an addition between two encrypted values without overflow check.
     * @param leftHandOperand Left-hand side operand handle
     * @param rightHandOperand Right-hand side operand handle
     * @return result Result handle
     */
    function add(
        bytes32 leftHandOperand,
        bytes32 rightHandOperand
    ) external returns (bytes32 result);

    /**
     * @notice Performs a subtraction between two encrypted values without underflow check.
     * @param leftHandOperand Left-hand side operand handle
     * @param rightHandOperand Right-hand side operand handle
     * @return result Result handle
     */
    function sub(
        bytes32 leftHandOperand,
        bytes32 rightHandOperand
    ) external returns (bytes32 result);

    /**
     * @notice Performs a multiplication between two encrypted values without overflow check.
     * @param leftHandOperand Left-hand side operand handle
     * @param rightHandOperand Right-hand side operand handle
     * @return result Result handle
     */
    function mul(
        bytes32 leftHandOperand,
        bytes32 rightHandOperand
    ) external returns (bytes32 result);

    /**
     * @notice Performs a division between two encrypted values without safety checks.
     * In the case of a division by zero, the result will be as follows:
     *  - For unsigned integers uintN: encrypted MAX_UintN (i.e., 2^N - 1)
     *  - For signed integers intN: encrypted MAX_IntN (i.e., 2^(N-1) - 1)
     * @param numerator Value to be divided
     * @param denominator Value to divide by
     * @return result Result handle
     */
    function div(bytes32 numerator, bytes32 denominator) external returns (bytes32 result);

    /**
     * @notice Performs an addition between two encrypted values with overflow check.
     * If the operation succeeds, the value of the success handle will be an encrypted
     * `true` and the result handle's value will be the encrypted sum.
     * If the operation fails (e.g., due to overflow), the success handle will contain
     * an encrypted `false` and the result handle will contain an encrypted `0`.
     * @param leftHandOperand Left-hand side operand handle
     * @param rightHandOperand Right-hand side operand handle
     * @return success Whether the operation was successful
     * @return result Result handle
     */
    function safeAdd(
        bytes32 leftHandOperand,
        bytes32 rightHandOperand
    ) external returns (bytes32 success, bytes32 result);

    /**
     * @notice Performs a subtraction between two encrypted values with underflow check.
     * If the operation succeeds, the value of the success handle will be an encrypted
     * `true` and the result handle's value will be the encrypted difference.
     * If the operation fails (e.g., due to underflow), the success handle will contain
     * an encrypted `false` and the result handle will contain an encrypted `0`.
     * @param leftHandOperand Left-hand side operand handle
     * @param rightHandOperand Right-hand side operand handle
     * @return success Whether the operation was successful
     * @return result Result handle
     */
    function safeSub(
        bytes32 leftHandOperand,
        bytes32 rightHandOperand
    ) external returns (bytes32 success, bytes32 result);

    /**
     * @notice Performs a multiplication between two encrypted values with overflow check.
     * If the operation succeeds, the value of the success handle will be an encrypted
     * `true` and the result handle's value will be the encrypted product.
     * If the operation fails (e.g., due to overflow), the success handle will contain
     * an encrypted `false` and the result handle will contain an encrypted `0`.
     * @param leftHandOperand Left-hand side operand handle
     * @param rightHandOperand Right-hand side operand handle
     * @return success Whether the operation was successful
     * @return result Result handle
     */
    function safeMul(
        bytes32 leftHandOperand,
        bytes32 rightHandOperand
    ) external returns (bytes32 success, bytes32 result);

    /**
     * @notice Performs a division between two encrypted values with division-by-zero check.
     * If the operation succeeds, the value of the success handle will be an encrypted
     * `true` and the result handle's value will be the encrypted quotient.
     * If the operation fails (e.g., due to division by zero), the success handle will contain
     * an encrypted `false` and the result handle will contain an encrypted `0`.
     * @param numerator Value to be divided
     * @param denominator Value to divide by
     * @return success Whether the operation was successful
     * @return result Result handle
     */
    function safeDiv(
        bytes32 numerator,
        bytes32 denominator
    ) external returns (bytes32 success, bytes32 result);

    /**
     * @notice Selects between two encrypted values based on a condition
     * @param condition Condition handle
     * @param ifTrue Value handle if condition is true
     * @param ifFalse Value handle if condition is false
     * @return result Selected value handle
     */
    function select(bytes32 condition, bytes32 ifTrue, bytes32 ifFalse) external returns (bytes32);

    /**
     * @notice Checks equality between two encrypted values
     * @param leftHandOperand Left-hand side operand handle
     * @param rightHandOperand Right-hand side operand handle
     * @return result Bool handle indicating equality
     */
    function eq(
        bytes32 leftHandOperand,
        bytes32 rightHandOperand
    ) external returns (bytes32 result);

    /**
     * @notice Checks inequality between two encrypted values
     * @param leftHandOperand Left-hand side operand handle
     * @param rightHandOperand Right-hand side operand handle
     * @return result Bool handle indicating inequality
     */
    function ne(
        bytes32 leftHandOperand,
        bytes32 rightHandOperand
    ) external returns (bytes32 result);

    /**
     * @notice Checks if left operand is less than right operand
     * @param leftHandOperand Left-hand side operand handle
     * @param rightHandOperand Right-hand side operand handle
     * @return result Bool handle indicating less than
     */
    function lt(
        bytes32 leftHandOperand,
        bytes32 rightHandOperand
    ) external returns (bytes32 result);

    /**
     * @notice Checks if left operand is less than or equal to right operand
     * @param leftHandOperand Left-hand side operand handle
     * @param rightHandOperand Right-hand side operand handle
     * @return result Bool handle indicating less than or equal
     */
    function le(
        bytes32 leftHandOperand,
        bytes32 rightHandOperand
    ) external returns (bytes32 result);

    /**
     * @notice Checks if left operand is greater than right operand
     * @param leftHandOperand Left-hand side operand handle
     * @param rightHandOperand Right-hand side operand handle
     * @return result Bool handle indicating greater than
     */
    function gt(
        bytes32 leftHandOperand,
        bytes32 rightHandOperand
    ) external returns (bytes32 result);

    /**
     * @notice Checks if left operand is greater than or equal to right operand
     * @param leftHandOperand Left-hand side operand handle
     * @param rightHandOperand Right-hand side operand handle
     * @return result Bool handle indicating greater than or equal
     */
    function ge(
        bytes32 leftHandOperand,
        bytes32 rightHandOperand
    ) external returns (bytes32 result);

    /**
     * @notice Computes a confidential transfer between two balances.
     * The transfer will succeed if the sender has sufficient balance and fail otherwise.
     * If the transfer fails, the success handle will contain an encrypted `false`, the
     * newBalanceFrom and newBalanceTo handles will contain the same values as the input
     * balanceFrom and balanceTo handles.
     * @param balanceFrom Sender's current balance handle
     * @param balanceTo Recipient's current balance handle
     * @param amount Amount handle to transfer
     * @return success Bool handle indicating if the transfer succeeded
     * @return newBalanceFrom Sender's new balance handle
     * @return newBalanceTo Recipient's new balance handle
     */
    function transfer(
        bytes32 balanceFrom,
        bytes32 balanceTo,
        bytes32 amount
    ) external returns (bytes32 success, bytes32 newBalanceFrom, bytes32 newBalanceTo);

    /**
     * @notice Computes a confidential mint operation.
     * If the minting operation fails (e.g., due to overflow), the success handle will
     * contain an encrypted `false` and the newBalanceTo and newTotalSupply handles will
     * contain the same values as the input balanceTo and totalSupply handles.
     * @param balanceTo Recipient's current balance handle
     * @param amount Amount handle to mint
     * @param totalSupply Current total supply handle
     * @return success Bool handle indicating if the mint succeeded
     * @return newBalanceTo Recipient's new balance handle
     * @return newTotalSupply New total supply handle
     */
    function mint(
        bytes32 balanceTo,
        bytes32 amount,
        bytes32 totalSupply
    ) external returns (bytes32 success, bytes32 newBalanceTo, bytes32 newTotalSupply);

    /**
     * @notice Computes a confidential burn operation.
     * If the burn operation fails (e.g., due to underflow), the success handle will
     * contain an encrypted `false` and the newBalanceFrom and newTotalSupply handles will
     * contain the same values as the input balanceFrom and totalSupply handles.
     * @param balanceFrom Sender's current balance handle
     * @param amount Amount handle to burn
     * @param totalSupply Current total supply handle
     * @return success Bool handle indicating if the burn succeeded
     * @return newBalanceFrom Sender's new balance handle
     * @return newTotalSupply New total supply handle
     */
    function burn(
        bytes32 balanceFrom,
        bytes32 amount,
        bytes32 totalSupply
    ) external returns (bytes32 success, bytes32 newBalanceFrom, bytes32 newTotalSupply);

    // ------------- Admin functions -------------

    /**
     * @notice Sets the KMS public key used for ECIES encryption.
     * @param newKmsPublicKey The compressed SEC1 secp256k1 public key (33 bytes)
     */
    function setKmsPublicKey(bytes calldata newKmsPublicKey) external;

    /**
     * @notice Sets the gateway address in the contract's config.
     * @param gatewayAddress The address of the gateway
     */
    function setGateway(address gatewayAddress) external;

    /**
     * @notice Sets the proof expiration duration.
     * @param newDuration The new expiration duration in seconds
     */
    function setProofExpirationDuration(uint256 newDuration) external;

    function kmsPublicKey() external view returns (bytes memory);
    function gateway() external view returns (address);
    function proofExpirationDuration() external view returns (uint256);
}


// File npm/@iexec-nox/nox-protocol-contracts@0.2.2/contracts/shared/HandleUtils.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.27;

library HandleUtils {
    /// @dev Bit 0 of the attrs byte. When set, the handle is guaranteed unique on-chain.
    bytes1 internal constant ATTR_IS_UNIQUE_HANDLE = 0x01;

    /**
     * @notice Checks if a handle is a public handle (isUniqueHandle bit == 0).
     * A public handle wraps a plaintext value known on-chain, has no ACL,
     * and is accessible by everyone.
     * @param handle The handle to check
     * @return True if the handle is a public handle
     */
    function isPublicHandle(bytes32 handle) internal pure returns (bool) {
        return (handle[6] & ATTR_IS_UNIQUE_HANDLE) == 0;
    }

    /**
     * @notice Returns the zero handle for the given TEE type on the current chain.
     * The zero handle represents the default zero value for a given type and is a public handle.
     * It follows the standard handle format but with a zeroed pre-handle:
     *   [0]=version(0x00)  [1-4]=chainId  [5]=teeType  [6]=attrs(0x00)  [7-31]=0x00..00
     * @param teeType The TEE type to encode
     * @return The typed null handle
     */
    function zeroHandle(TEEType teeType) internal view returns (bytes32) {
        return
            // [0]=version is implicitly 0x00
            (bytes32(bytes4(uint32(block.chainid))) >> (1 * 8)) |
            (bytes32(bytes1(uint8(teeType))) >> (5 * 8));
    }
}


// File npm/encrypted-types@0.0.4/EncryptedTypes.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.24;

type ebool is bytes32;

type euint8 is bytes32;
type euint16 is bytes32;
type euint24 is bytes32;
type euint32 is bytes32;
type euint40 is bytes32;
type euint48 is bytes32;
type euint56 is bytes32;
type euint64 is bytes32;
type euint72 is bytes32;
type euint80 is bytes32;
type euint88 is bytes32;
type euint96 is bytes32;
type euint104 is bytes32;
type euint112 is bytes32;
type euint120 is bytes32;
type euint128 is bytes32;
type euint136 is bytes32;
type euint144 is bytes32;
type euint152 is bytes32;
type euint160 is bytes32;
type euint168 is bytes32;
type euint176 is bytes32;
type euint184 is bytes32;
type euint192 is bytes32;
type euint200 is bytes32;
type euint208 is bytes32;
type euint216 is bytes32;
type euint224 is bytes32;
type euint232 is bytes32;
type euint240 is bytes32;
type euint248 is bytes32;
type euint256 is bytes32;

type eint8 is bytes32;
type eint16 is bytes32;
type eint24 is bytes32;
type eint32 is bytes32;
type eint40 is bytes32;
type eint48 is bytes32;
type eint56 is bytes32;
type eint64 is bytes32;
type eint72 is bytes32;
type eint80 is bytes32;
type eint88 is bytes32;
type eint96 is bytes32;
type eint104 is bytes32;
type eint112 is bytes32;
type eint120 is bytes32;
type eint128 is bytes32;
type eint136 is bytes32;
type eint144 is bytes32;
type eint152 is bytes32;
type eint160 is bytes32;
type eint168 is bytes32;
type eint176 is bytes32;
type eint184 is bytes32;
type eint192 is bytes32;
type eint200 is bytes32;
type eint208 is bytes32;
type eint216 is bytes32;
type eint224 is bytes32;
type eint232 is bytes32;
type eint240 is bytes32;
type eint248 is bytes32;
type eint256 is bytes32;

type eaddress is bytes32;

type ebytes1 is bytes32;
type ebytes2 is bytes32;
type ebytes3 is bytes32;
type ebytes4 is bytes32;
type ebytes5 is bytes32;
type ebytes6 is bytes32;
type ebytes7 is bytes32;
type ebytes8 is bytes32;
type ebytes9 is bytes32;
type ebytes10 is bytes32;
type ebytes11 is bytes32;
type ebytes12 is bytes32;
type ebytes13 is bytes32;
type ebytes14 is bytes32;
type ebytes15 is bytes32;
type ebytes16 is bytes32;
type ebytes17 is bytes32;
type ebytes18 is bytes32;
type ebytes19 is bytes32;
type ebytes20 is bytes32;
type ebytes21 is bytes32;
type ebytes22 is bytes32;
type ebytes23 is bytes32;
type ebytes24 is bytes32;
type ebytes25 is bytes32;
type ebytes26 is bytes32;
type ebytes27 is bytes32;
type ebytes28 is bytes32;
type ebytes29 is bytes32;
type ebytes30 is bytes32;
type ebytes31 is bytes32;
type ebytes32 is bytes32;

type externalEbool is bytes32;

type externalEuint8 is bytes32;
type externalEuint16 is bytes32;
type externalEuint24 is bytes32;
type externalEuint32 is bytes32;
type externalEuint40 is bytes32;
type externalEuint48 is bytes32;
type externalEuint56 is bytes32;
type externalEuint64 is bytes32;
type externalEuint72 is bytes32;
type externalEuint80 is bytes32;
type externalEuint88 is bytes32;
type externalEuint96 is bytes32;
type externalEuint104 is bytes32;
type externalEuint112 is bytes32;
type externalEuint120 is bytes32;
type externalEuint128 is bytes32;
type externalEuint136 is bytes32;
type externalEuint144 is bytes32;
type externalEuint152 is bytes32;
type externalEuint160 is bytes32;
type externalEuint168 is bytes32;
type externalEuint176 is bytes32;
type externalEuint184 is bytes32;
type externalEuint192 is bytes32;
type externalEuint200 is bytes32;
type externalEuint208 is bytes32;
type externalEuint216 is bytes32;
type externalEuint224 is bytes32;
type externalEuint232 is bytes32;
type externalEuint240 is bytes32;
type externalEuint248 is bytes32;
type externalEuint256 is bytes32;

type externalEint8 is bytes32;
type externalEint16 is bytes32;
type externalEint24 is bytes32;
type externalEint32 is bytes32;
type externalEint40 is bytes32;
type externalEint48 is bytes32;
type externalEint56 is bytes32;
type externalEint64 is bytes32;
type externalEint72 is bytes32;
type externalEint80 is bytes32;
type externalEint88 is bytes32;
type externalEint96 is bytes32;
type externalEint104 is bytes32;
type externalEint112 is bytes32;
type externalEint120 is bytes32;
type externalEint128 is bytes32;
type externalEint136 is bytes32;
type externalEint144 is bytes32;
type externalEint152 is bytes32;
type externalEint160 is bytes32;
type externalEint168 is bytes32;
type externalEint176 is bytes32;
type externalEint184 is bytes32;
type externalEint192 is bytes32;
type externalEint200 is bytes32;
type externalEint208 is bytes32;
type externalEint216 is bytes32;
type externalEint224 is bytes32;
type externalEint232 is bytes32;
type externalEint240 is bytes32;
type externalEint248 is bytes32;
type externalEint256 is bytes32;

type externalEaddress is bytes32;

type externalEbytes1 is bytes32;
type externalEbytes2 is bytes32;
type externalEbytes3 is bytes32;
type externalEbytes4 is bytes32;
type externalEbytes5 is bytes32;
type externalEbytes6 is bytes32;
type externalEbytes7 is bytes32;
type externalEbytes8 is bytes32;
type externalEbytes9 is bytes32;
type externalEbytes10 is bytes32;
type externalEbytes11 is bytes32;
type externalEbytes12 is bytes32;
type externalEbytes13 is bytes32;
type externalEbytes14 is bytes32;
type externalEbytes15 is bytes32;
type externalEbytes16 is bytes32;
type externalEbytes17 is bytes32;
type externalEbytes18 is bytes32;
type externalEbytes19 is bytes32;
type externalEbytes20 is bytes32;
type externalEbytes21 is bytes32;
type externalEbytes22 is bytes32;
type externalEbytes23 is bytes32;
type externalEbytes24 is bytes32;
type externalEbytes25 is bytes32;
type externalEbytes26 is bytes32;
type externalEbytes27 is bytes32;
type externalEbytes28 is bytes32;
type externalEbytes29 is bytes32;
type externalEbytes30 is bytes32;
type externalEbytes31 is bytes32;
type externalEbytes32 is bytes32;


// File npm/@iexec-nox/nox-protocol-contracts@0.2.2/contracts/sdk/Nox.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.27;




/**
 * @title Nox
 * @notice Library providing convenient functions for TEE confidential computations.
 */
library Nox {
    // ============ Errors ============

    error MalformedDecryptedData(bytes data);

    // ============ Address resolution ============

    /**
     * @dev Returns the NoxCompute contract address for the current chain.
     *      Supports Arbitrum Mainnet (42161), Arbitrum Sepolia (421614), and local dev chains (31337),
     *      including local forks of each network.
     */
    function noxComputeContract() internal view returns (address) {
        // Arbitrum mainnet or its fork
        if (block.chainid == 42161) {
            // TODO: Update after mainnet deployment.
            return address(0);
        }
        // Arbitrum Sepolia or its fork
        if (block.chainid == 421614) {
            return 0xd464B198f06756a1d00be223634b85E0a731c229;
        }
        // Local development chain
        if (block.chainid == 31337) {
            return 0x44C00793aD4975617b3B5Fc27D4FB78E772c8236;
        }
        revert("Nox: Unsupported chain");
    }

    function _noxComputeContract() private view returns (INoxCompute) {
        return INoxCompute(noxComputeContract());
    }

    /**
     * @dev Calls allow on NoxCompute, silently skipping public handles.
     * Public handles are already accessible by everyone and don't need ACL.
     */
    function _allowIfNotPublic(bytes32 handle, address account) private {
        if (!HandleUtils.isPublicHandle(handle)) {
            _noxComputeContract().allow(handle, account);
        }
    }

    /**
     * @dev Calls allowTransient on NoxCompute, silently skipping public handles.
     * Public handles are already accessible by everyone and don't need ACL.
     */
    function _allowTransientIfNotPublic(bytes32 handle, address account) private {
        if (!HandleUtils.isPublicHandle(handle)) {
            _noxComputeContract().allowTransient(handle, account);
        }
    }

    /**
     * @dev Calls disallowTransient on NoxCompute, silently skipping public handles.
     * Public handles are already accessible by everyone and don't need ACL.
     */
    function _disallowTransientIfNotPublic(bytes32 handle, address account) private {
        if (!HandleUtils.isPublicHandle(handle)) {
            _noxComputeContract().disallowTransient(handle, account);
        }
    }

    // =========== Handle initialization checks ============

    /**
     * @dev Checks if an encrypted boolean handle is initialized.
     * This is a basic check and does not guarantee that the handle
     * is valid or recognized by the ACL.
     * @param handle encrypted boolean handle
     */
    function isInitialized(ebool handle) internal pure returns (bool) {
        return ebool.unwrap(handle) != 0;
    }

    /**
     * @dev Checks if an encrypted uint16 handle is initialized.
     * This is a basic check and does not guarantee that the handle
     * is valid or recognized by the ACL.
     * @param handle encrypted uint16 handle
     */
    function isInitialized(euint16 handle) internal pure returns (bool) {
        return euint16.unwrap(handle) != 0;
    }

    /**
     * @dev Checks if an encrypted uint256 handle is initialized.
     * This is a basic check and does not guarantee that the handle
     * is valid or recognized by the ACL.
     * @param handle encrypted uint256 handle
     */
    function isInitialized(euint256 handle) internal pure returns (bool) {
        return euint256.unwrap(handle) != 0;
    }

    /**
     * @dev Checks if an encrypted int16 handle is initialized.
     * This is a basic check and does not guarantee that the handle
     * is valid or recognized by the ACL.
     * @param handle encrypted int16 handle
     */
    function isInitialized(eint16 handle) internal pure returns (bool) {
        return eint16.unwrap(handle) != 0;
    }

    /**
     * @dev Checks if an encrypted int256 handle is initialized.
     * This is a basic check and does not guarantee that the handle
     * is valid or recognized by the ACL.
     * @param handle encrypted int256 handle
     */
    function isInitialized(eint256 handle) internal pure returns (bool) {
        return eint256.unwrap(handle) != 0;
    }

    // ============ Trivial Encryption Functions ============

    /**
     * @dev Converts a plaintext boolean to an encrypted boolean.
     */
    function toEbool(bool value) internal returns (ebool) {
        return
            ebool.wrap(
                _noxComputeContract().wrapAsPublicHandle(
                    bytes32(uint256(value ? 1 : 0)),
                    TEEType.Bool
                )
            );
    }

    /**
     * @dev Convert a plaintext value to an encrypted euint16 integer.
     */
    function toEuint16(uint16 value) internal returns (euint16) {
        return
            euint16.wrap(
                _noxComputeContract().wrapAsPublicHandle(bytes32(uint256(value)), TEEType.Uint16)
            );
    }

    /**
     * @dev Convert a plaintext value to an encrypted euint256 integer.
     */
    function toEuint256(uint256 value) internal returns (euint256) {
        return
            euint256.wrap(
                _noxComputeContract().wrapAsPublicHandle(bytes32(value), TEEType.Uint256)
            );
    }

    /**
     * @dev Convert a plaintext value to an encrypted eint16 integer.
     */
    function toEint16(int16 value) internal returns (eint16) {
        return
            eint16.wrap(
                _noxComputeContract().wrapAsPublicHandle(
                    bytes32(uint256(uint16(value))),
                    TEEType.Int16
                )
            );
    }

    /**
     * @dev Convert a plaintext value to an encrypted eint256 integer.
     */
    function toEint256(int256 value) internal returns (eint256) {
        return
            eint256.wrap(
                _noxComputeContract().wrapAsPublicHandle(bytes32(uint256(value)), TEEType.Int256)
            );
    }

    // ============ Handle validation ============

    function fromExternal(
        externalEbool externalHandle,
        bytes calldata handleProof
    ) internal returns (ebool) {
        bytes32 handle = externalEbool.unwrap(externalHandle);
        _noxComputeContract().validateInputProof(handle, msg.sender, handleProof, TEEType.Bool);
        return ebool.wrap(handle);
    }

    function fromExternal(
        externalEuint16 externalHandle,
        bytes calldata handleProof
    ) internal returns (euint16) {
        bytes32 handle = externalEuint16.unwrap(externalHandle);
        _noxComputeContract().validateInputProof(handle, msg.sender, handleProof, TEEType.Uint16);
        return euint16.wrap(handle);
    }

    function fromExternal(
        externalEuint256 externalHandle,
        bytes calldata handleProof
    ) internal returns (euint256) {
        bytes32 handle = externalEuint256.unwrap(externalHandle);
        _noxComputeContract().validateInputProof(handle, msg.sender, handleProof, TEEType.Uint256);
        return euint256.wrap(handle);
    }

    function fromExternal(
        externalEint16 externalHandle,
        bytes calldata handleProof
    ) internal returns (eint16) {
        bytes32 handle = externalEint16.unwrap(externalHandle);
        _noxComputeContract().validateInputProof(handle, msg.sender, handleProof, TEEType.Int16);
        return eint16.wrap(handle);
    }

    function fromExternal(
        externalEint256 externalHandle,
        bytes calldata handleProof
    ) internal returns (eint256) {
        bytes32 handle = externalEint256.unwrap(externalHandle);
        _noxComputeContract().validateInputProof(handle, msg.sender, handleProof, TEEType.Int256);
        return eint256.wrap(handle);
    }

    // ============ Arithmetic primitives ============

    function add(euint16 a, euint16 b) internal returns (euint16) {
        return
            euint16.wrap(
                _noxComputeContract().add(
                    _resolveUndefinedHandle(euint16.unwrap(a), TEEType.Uint16),
                    _resolveUndefinedHandle(euint16.unwrap(b), TEEType.Uint16)
                )
            );
    }

    function add(euint256 a, euint256 b) internal returns (euint256) {
        return
            euint256.wrap(
                _noxComputeContract().add(
                    _resolveUndefinedHandle(euint256.unwrap(a), TEEType.Uint256),
                    _resolveUndefinedHandle(euint256.unwrap(b), TEEType.Uint256)
                )
            );
    }

    function add(eint16 a, eint16 b) internal returns (eint16) {
        return
            eint16.wrap(
                _noxComputeContract().add(
                    _resolveUndefinedHandle(eint16.unwrap(a), TEEType.Int16),
                    _resolveUndefinedHandle(eint16.unwrap(b), TEEType.Int16)
                )
            );
    }

    function add(eint256 a, eint256 b) internal returns (eint256) {
        return
            eint256.wrap(
                _noxComputeContract().add(
                    _resolveUndefinedHandle(eint256.unwrap(a), TEEType.Int256),
                    _resolveUndefinedHandle(eint256.unwrap(b), TEEType.Int256)
                )
            );
    }

    function sub(euint16 a, euint16 b) internal returns (euint16) {
        return
            euint16.wrap(
                _noxComputeContract().sub(
                    _resolveUndefinedHandle(euint16.unwrap(a), TEEType.Uint16),
                    _resolveUndefinedHandle(euint16.unwrap(b), TEEType.Uint16)
                )
            );
    }

    function sub(euint256 a, euint256 b) internal returns (euint256) {
        return
            euint256.wrap(
                _noxComputeContract().sub(
                    _resolveUndefinedHandle(euint256.unwrap(a), TEEType.Uint256),
                    _resolveUndefinedHandle(euint256.unwrap(b), TEEType.Uint256)
                )
            );
    }

    function sub(eint16 a, eint16 b) internal returns (eint16) {
        return
            eint16.wrap(
                _noxComputeContract().sub(
                    _resolveUndefinedHandle(eint16.unwrap(a), TEEType.Int16),
                    _resolveUndefinedHandle(eint16.unwrap(b), TEEType.Int16)
                )
            );
    }

    function sub(eint256 a, eint256 b) internal returns (eint256) {
        return
            eint256.wrap(
                _noxComputeContract().sub(
                    _resolveUndefinedHandle(eint256.unwrap(a), TEEType.Int256),
                    _resolveUndefinedHandle(eint256.unwrap(b), TEEType.Int256)
                )
            );
    }

    function mul(euint16 a, euint16 b) internal returns (euint16) {
        return
            euint16.wrap(
                _noxComputeContract().mul(
                    _resolveUndefinedHandle(euint16.unwrap(a), TEEType.Uint16),
                    _resolveUndefinedHandle(euint16.unwrap(b), TEEType.Uint16)
                )
            );
    }

    function mul(euint256 a, euint256 b) internal returns (euint256) {
        return
            euint256.wrap(
                _noxComputeContract().mul(
                    _resolveUndefinedHandle(euint256.unwrap(a), TEEType.Uint256),
                    _resolveUndefinedHandle(euint256.unwrap(b), TEEType.Uint256)
                )
            );
    }

    function mul(eint16 a, eint16 b) internal returns (eint16) {
        return
            eint16.wrap(
                _noxComputeContract().mul(
                    _resolveUndefinedHandle(eint16.unwrap(a), TEEType.Int16),
                    _resolveUndefinedHandle(eint16.unwrap(b), TEEType.Int16)
                )
            );
    }

    function mul(eint256 a, eint256 b) internal returns (eint256) {
        return
            eint256.wrap(
                _noxComputeContract().mul(
                    _resolveUndefinedHandle(eint256.unwrap(a), TEEType.Int256),
                    _resolveUndefinedHandle(eint256.unwrap(b), TEEType.Int256)
                )
            );
    }

    function div(euint16 a, euint16 b) internal returns (euint16) {
        return
            euint16.wrap(
                _noxComputeContract().div(
                    _resolveUndefinedHandle(euint16.unwrap(a), TEEType.Uint16),
                    _resolveUndefinedHandle(euint16.unwrap(b), TEEType.Uint16)
                )
            );
    }

    function div(euint256 a, euint256 b) internal returns (euint256) {
        return
            euint256.wrap(
                _noxComputeContract().div(
                    _resolveUndefinedHandle(euint256.unwrap(a), TEEType.Uint256),
                    _resolveUndefinedHandle(euint256.unwrap(b), TEEType.Uint256)
                )
            );
    }

    function div(eint16 a, eint16 b) internal returns (eint16) {
        return
            eint16.wrap(
                _noxComputeContract().div(
                    _resolveUndefinedHandle(eint16.unwrap(a), TEEType.Int16),
                    _resolveUndefinedHandle(eint16.unwrap(b), TEEType.Int16)
                )
            );
    }

    function div(eint256 a, eint256 b) internal returns (eint256) {
        return
            eint256.wrap(
                _noxComputeContract().div(
                    _resolveUndefinedHandle(eint256.unwrap(a), TEEType.Int256),
                    _resolveUndefinedHandle(eint256.unwrap(b), TEEType.Int256)
                )
            );
    }

    function safeAdd(euint16 a, euint16 b) internal returns (ebool, euint16) {
        (bytes32 success, bytes32 result) = _noxComputeContract().safeAdd(
            _resolveUndefinedHandle(euint16.unwrap(a), TEEType.Uint16),
            _resolveUndefinedHandle(euint16.unwrap(b), TEEType.Uint16)
        );
        return (ebool.wrap(success), euint16.wrap(result));
    }

    function safeAdd(euint256 a, euint256 b) internal returns (ebool, euint256) {
        (bytes32 success, bytes32 result) = _noxComputeContract().safeAdd(
            _resolveUndefinedHandle(euint256.unwrap(a), TEEType.Uint256),
            _resolveUndefinedHandle(euint256.unwrap(b), TEEType.Uint256)
        );
        return (ebool.wrap(success), euint256.wrap(result));
    }

    function safeAdd(eint16 a, eint16 b) internal returns (ebool, eint16) {
        (bytes32 success, bytes32 result) = _noxComputeContract().safeAdd(
            _resolveUndefinedHandle(eint16.unwrap(a), TEEType.Int16),
            _resolveUndefinedHandle(eint16.unwrap(b), TEEType.Int16)
        );
        return (ebool.wrap(success), eint16.wrap(result));
    }

    function safeAdd(eint256 a, eint256 b) internal returns (ebool, eint256) {
        (bytes32 success, bytes32 result) = _noxComputeContract().safeAdd(
            _resolveUndefinedHandle(eint256.unwrap(a), TEEType.Int256),
            _resolveUndefinedHandle(eint256.unwrap(b), TEEType.Int256)
        );
        return (ebool.wrap(success), eint256.wrap(result));
    }

    function safeSub(euint16 a, euint16 b) internal returns (ebool, euint16) {
        (bytes32 success, bytes32 result) = _noxComputeContract().safeSub(
            _resolveUndefinedHandle(euint16.unwrap(a), TEEType.Uint16),
            _resolveUndefinedHandle(euint16.unwrap(b), TEEType.Uint16)
        );
        return (ebool.wrap(success), euint16.wrap(result));
    }

    function safeSub(euint256 a, euint256 b) internal returns (ebool, euint256) {
        (bytes32 success, bytes32 result) = _noxComputeContract().safeSub(
            _resolveUndefinedHandle(euint256.unwrap(a), TEEType.Uint256),
            _resolveUndefinedHandle(euint256.unwrap(b), TEEType.Uint256)
        );
        return (ebool.wrap(success), euint256.wrap(result));
    }

    function safeSub(eint16 a, eint16 b) internal returns (ebool, eint16) {
        (bytes32 success, bytes32 result) = _noxComputeContract().safeSub(
            _resolveUndefinedHandle(eint16.unwrap(a), TEEType.Int16),
            _resolveUndefinedHandle(eint16.unwrap(b), TEEType.Int16)
        );
        return (ebool.wrap(success), eint16.wrap(result));
    }

    function safeSub(eint256 a, eint256 b) internal returns (ebool, eint256) {
        (bytes32 success, bytes32 result) = _noxComputeContract().safeSub(
            _resolveUndefinedHandle(eint256.unwrap(a), TEEType.Int256),
            _resolveUndefinedHandle(eint256.unwrap(b), TEEType.Int256)
        );
        return (ebool.wrap(success), eint256.wrap(result));
    }

    function safeMul(euint16 a, euint16 b) internal returns (ebool, euint16) {
        (bytes32 success, bytes32 result) = _noxComputeContract().safeMul(
            _resolveUndefinedHandle(euint16.unwrap(a), TEEType.Uint16),
            _resolveUndefinedHandle(euint16.unwrap(b), TEEType.Uint16)
        );
        return (ebool.wrap(success), euint16.wrap(result));
    }

    function safeMul(euint256 a, euint256 b) internal returns (ebool, euint256) {
        (bytes32 success, bytes32 result) = _noxComputeContract().safeMul(
            _resolveUndefinedHandle(euint256.unwrap(a), TEEType.Uint256),
            _resolveUndefinedHandle(euint256.unwrap(b), TEEType.Uint256)
        );
        return (ebool.wrap(success), euint256.wrap(result));
    }

    function safeMul(eint16 a, eint16 b) internal returns (ebool, eint16) {
        (bytes32 success, bytes32 result) = _noxComputeContract().safeMul(
            _resolveUndefinedHandle(eint16.unwrap(a), TEEType.Int16),
            _resolveUndefinedHandle(eint16.unwrap(b), TEEType.Int16)
        );
        return (ebool.wrap(success), eint16.wrap(result));
    }

    function safeMul(eint256 a, eint256 b) internal returns (ebool, eint256) {
        (bytes32 success, bytes32 result) = _noxComputeContract().safeMul(
            _resolveUndefinedHandle(eint256.unwrap(a), TEEType.Int256),
            _resolveUndefinedHandle(eint256.unwrap(b), TEEType.Int256)
        );
        return (ebool.wrap(success), eint256.wrap(result));
    }

    function safeDiv(euint16 a, euint16 b) internal returns (ebool, euint16) {
        (bytes32 success, bytes32 result) = _noxComputeContract().safeDiv(
            _resolveUndefinedHandle(euint16.unwrap(a), TEEType.Uint16),
            _resolveUndefinedHandle(euint16.unwrap(b), TEEType.Uint16)
        );
        return (ebool.wrap(success), euint16.wrap(result));
    }

    function safeDiv(euint256 a, euint256 b) internal returns (ebool, euint256) {
        (bytes32 success, bytes32 result) = _noxComputeContract().safeDiv(
            _resolveUndefinedHandle(euint256.unwrap(a), TEEType.Uint256),
            _resolveUndefinedHandle(euint256.unwrap(b), TEEType.Uint256)
        );
        return (ebool.wrap(success), euint256.wrap(result));
    }

    function safeDiv(eint16 a, eint16 b) internal returns (ebool, eint16) {
        (bytes32 success, bytes32 result) = _noxComputeContract().safeDiv(
            _resolveUndefinedHandle(eint16.unwrap(a), TEEType.Int16),
            _resolveUndefinedHandle(eint16.unwrap(b), TEEType.Int16)
        );
        return (ebool.wrap(success), eint16.wrap(result));
    }

    function safeDiv(eint256 a, eint256 b) internal returns (ebool, eint256) {
        (bytes32 success, bytes32 result) = _noxComputeContract().safeDiv(
            _resolveUndefinedHandle(eint256.unwrap(a), TEEType.Int256),
            _resolveUndefinedHandle(eint256.unwrap(b), TEEType.Int256)
        );
        return (ebool.wrap(success), eint256.wrap(result));
    }

    function select(ebool condition, euint16 ifTrue, euint16 ifFalse) internal returns (euint16) {
        return
            euint16.wrap(
                _noxComputeContract().select(
                    _resolveUndefinedHandle(ebool.unwrap(condition), TEEType.Bool),
                    _resolveUndefinedHandle(euint16.unwrap(ifTrue), TEEType.Uint16),
                    _resolveUndefinedHandle(euint16.unwrap(ifFalse), TEEType.Uint16)
                )
            );
    }

    function select(
        ebool condition,
        euint256 ifTrue,
        euint256 ifFalse
    ) internal returns (euint256) {
        return
            euint256.wrap(
                _noxComputeContract().select(
                    _resolveUndefinedHandle(ebool.unwrap(condition), TEEType.Bool),
                    _resolveUndefinedHandle(euint256.unwrap(ifTrue), TEEType.Uint256),
                    _resolveUndefinedHandle(euint256.unwrap(ifFalse), TEEType.Uint256)
                )
            );
    }

    function select(ebool condition, eint16 ifTrue, eint16 ifFalse) internal returns (eint16) {
        return
            eint16.wrap(
                _noxComputeContract().select(
                    _resolveUndefinedHandle(ebool.unwrap(condition), TEEType.Bool),
                    _resolveUndefinedHandle(eint16.unwrap(ifTrue), TEEType.Int16),
                    _resolveUndefinedHandle(eint16.unwrap(ifFalse), TEEType.Int16)
                )
            );
    }

    function select(ebool condition, eint256 ifTrue, eint256 ifFalse) internal returns (eint256) {
        return
            eint256.wrap(
                _noxComputeContract().select(
                    _resolveUndefinedHandle(ebool.unwrap(condition), TEEType.Bool),
                    _resolveUndefinedHandle(eint256.unwrap(ifTrue), TEEType.Int256),
                    _resolveUndefinedHandle(eint256.unwrap(ifFalse), TEEType.Int256)
                )
            );
    }

    function eq(euint16 a, euint16 b) internal returns (ebool) {
        return
            ebool.wrap(
                _noxComputeContract().eq(
                    _resolveUndefinedHandle(euint16.unwrap(a), TEEType.Uint16),
                    _resolveUndefinedHandle(euint16.unwrap(b), TEEType.Uint16)
                )
            );
    }

    function eq(euint256 a, euint256 b) internal returns (ebool) {
        return
            ebool.wrap(
                _noxComputeContract().eq(
                    _resolveUndefinedHandle(euint256.unwrap(a), TEEType.Uint256),
                    _resolveUndefinedHandle(euint256.unwrap(b), TEEType.Uint256)
                )
            );
    }

    function eq(eint16 a, eint16 b) internal returns (ebool) {
        return
            ebool.wrap(
                _noxComputeContract().eq(
                    _resolveUndefinedHandle(eint16.unwrap(a), TEEType.Int16),
                    _resolveUndefinedHandle(eint16.unwrap(b), TEEType.Int16)
                )
            );
    }

    function eq(eint256 a, eint256 b) internal returns (ebool) {
        return
            ebool.wrap(
                _noxComputeContract().eq(
                    _resolveUndefinedHandle(eint256.unwrap(a), TEEType.Int256),
                    _resolveUndefinedHandle(eint256.unwrap(b), TEEType.Int256)
                )
            );
    }

    function ne(euint16 a, euint16 b) internal returns (ebool) {
        return
            ebool.wrap(
                _noxComputeContract().ne(
                    _resolveUndefinedHandle(euint16.unwrap(a), TEEType.Uint16),
                    _resolveUndefinedHandle(euint16.unwrap(b), TEEType.Uint16)
                )
            );
    }

    function ne(euint256 a, euint256 b) internal returns (ebool) {
        return
            ebool.wrap(
                _noxComputeContract().ne(
                    _resolveUndefinedHandle(euint256.unwrap(a), TEEType.Uint256),
                    _resolveUndefinedHandle(euint256.unwrap(b), TEEType.Uint256)
                )
            );
    }

    function ne(eint16 a, eint16 b) internal returns (ebool) {
        return
            ebool.wrap(
                _noxComputeContract().ne(
                    _resolveUndefinedHandle(eint16.unwrap(a), TEEType.Int16),
                    _resolveUndefinedHandle(eint16.unwrap(b), TEEType.Int16)
                )
            );
    }

    function ne(eint256 a, eint256 b) internal returns (ebool) {
        return
            ebool.wrap(
                _noxComputeContract().ne(
                    _resolveUndefinedHandle(eint256.unwrap(a), TEEType.Int256),
                    _resolveUndefinedHandle(eint256.unwrap(b), TEEType.Int256)
                )
            );
    }

    function lt(euint16 a, euint16 b) internal returns (ebool) {
        return
            ebool.wrap(
                _noxComputeContract().lt(
                    _resolveUndefinedHandle(euint16.unwrap(a), TEEType.Uint16),
                    _resolveUndefinedHandle(euint16.unwrap(b), TEEType.Uint16)
                )
            );
    }

    function lt(euint256 a, euint256 b) internal returns (ebool) {
        return
            ebool.wrap(
                _noxComputeContract().lt(
                    _resolveUndefinedHandle(euint256.unwrap(a), TEEType.Uint256),
                    _resolveUndefinedHandle(euint256.unwrap(b), TEEType.Uint256)
                )
            );
    }

    function lt(eint16 a, eint16 b) internal returns (ebool) {
        return
            ebool.wrap(
                _noxComputeContract().lt(
                    _resolveUndefinedHandle(eint16.unwrap(a), TEEType.Int16),
                    _resolveUndefinedHandle(eint16.unwrap(b), TEEType.Int16)
                )
            );
    }

    function lt(eint256 a, eint256 b) internal returns (ebool) {
        return
            ebool.wrap(
                _noxComputeContract().lt(
                    _resolveUndefinedHandle(eint256.unwrap(a), TEEType.Int256),
                    _resolveUndefinedHandle(eint256.unwrap(b), TEEType.Int256)
                )
            );
    }

    function le(euint16 a, euint16 b) internal returns (ebool) {
        return
            ebool.wrap(
                _noxComputeContract().le(
                    _resolveUndefinedHandle(euint16.unwrap(a), TEEType.Uint16),
                    _resolveUndefinedHandle(euint16.unwrap(b), TEEType.Uint16)
                )
            );
    }

    function le(euint256 a, euint256 b) internal returns (ebool) {
        return
            ebool.wrap(
                _noxComputeContract().le(
                    _resolveUndefinedHandle(euint256.unwrap(a), TEEType.Uint256),
                    _resolveUndefinedHandle(euint256.unwrap(b), TEEType.Uint256)
                )
            );
    }

    function le(eint16 a, eint16 b) internal returns (ebool) {
        return
            ebool.wrap(
                _noxComputeContract().le(
                    _resolveUndefinedHandle(eint16.unwrap(a), TEEType.Int16),
                    _resolveUndefinedHandle(eint16.unwrap(b), TEEType.Int16)
                )
            );
    }

    function le(eint256 a, eint256 b) internal returns (ebool) {
        return
            ebool.wrap(
                _noxComputeContract().le(
                    _resolveUndefinedHandle(eint256.unwrap(a), TEEType.Int256),
                    _resolveUndefinedHandle(eint256.unwrap(b), TEEType.Int256)
                )
            );
    }

    function gt(euint16 a, euint16 b) internal returns (ebool) {
        return
            ebool.wrap(
                _noxComputeContract().gt(
                    _resolveUndefinedHandle(euint16.unwrap(a), TEEType.Uint16),
                    _resolveUndefinedHandle(euint16.unwrap(b), TEEType.Uint16)
                )
            );
    }

    function gt(euint256 a, euint256 b) internal returns (ebool) {
        return
            ebool.wrap(
                _noxComputeContract().gt(
                    _resolveUndefinedHandle(euint256.unwrap(a), TEEType.Uint256),
                    _resolveUndefinedHandle(euint256.unwrap(b), TEEType.Uint256)
                )
            );
    }

    function gt(eint16 a, eint16 b) internal returns (ebool) {
        return
            ebool.wrap(
                _noxComputeContract().gt(
                    _resolveUndefinedHandle(eint16.unwrap(a), TEEType.Int16),
                    _resolveUndefinedHandle(eint16.unwrap(b), TEEType.Int16)
                )
            );
    }

    function gt(eint256 a, eint256 b) internal returns (ebool) {
        return
            ebool.wrap(
                _noxComputeContract().gt(
                    _resolveUndefinedHandle(eint256.unwrap(a), TEEType.Int256),
                    _resolveUndefinedHandle(eint256.unwrap(b), TEEType.Int256)
                )
            );
    }

    function ge(euint16 a, euint16 b) internal returns (ebool) {
        return
            ebool.wrap(
                _noxComputeContract().ge(
                    _resolveUndefinedHandle(euint16.unwrap(a), TEEType.Uint16),
                    _resolveUndefinedHandle(euint16.unwrap(b), TEEType.Uint16)
                )
            );
    }

    function ge(euint256 a, euint256 b) internal returns (ebool) {
        return
            ebool.wrap(
                _noxComputeContract().ge(
                    _resolveUndefinedHandle(euint256.unwrap(a), TEEType.Uint256),
                    _resolveUndefinedHandle(euint256.unwrap(b), TEEType.Uint256)
                )
            );
    }

    function ge(eint16 a, eint16 b) internal returns (ebool) {
        return
            ebool.wrap(
                _noxComputeContract().ge(
                    _resolveUndefinedHandle(eint16.unwrap(a), TEEType.Int16),
                    _resolveUndefinedHandle(eint16.unwrap(b), TEEType.Int16)
                )
            );
    }

    function ge(eint256 a, eint256 b) internal returns (ebool) {
        return
            ebool.wrap(
                _noxComputeContract().ge(
                    _resolveUndefinedHandle(eint256.unwrap(a), TEEType.Int256),
                    _resolveUndefinedHandle(eint256.unwrap(b), TEEType.Int256)
                )
            );
    }

    // ============ ADVANCED FUNCTIONS ============

    /**
     * @dev Atomically transfers `amount` from `balanceFrom` to `balanceTo`.
     * Returns the new balances and whether the transfer was successful.
     * The transfer will fail if `balanceFrom < amount`.
     */
    function transfer(
        euint256 balanceFrom,
        euint256 balanceTo,
        euint256 amount
    ) internal returns (ebool success, euint256 newBalanceFrom, euint256 newBalanceTo) {
        (bytes32 _success, bytes32 _newBalanceFrom, bytes32 _newBalanceTo) = _noxComputeContract()
            .transfer(
                _resolveUndefinedHandle(euint256.unwrap(balanceFrom), TEEType.Uint256),
                _resolveUndefinedHandle(euint256.unwrap(balanceTo), TEEType.Uint256),
                _resolveUndefinedHandle(euint256.unwrap(amount), TEEType.Uint256)
            );
        success = ebool.wrap(_success);
        newBalanceFrom = euint256.wrap(_newBalanceFrom);
        newBalanceTo = euint256.wrap(_newBalanceTo);
    }

    /**
     * @dev Atomically mints `amount` to `balanceTo` and increases `totalSupply` by `amount`.
     * Returns the new balance, new total supply, and whether the mint was successful.
     * The mint will fail if `totalSupply + amount` overflows.
     */
    function mint(
        euint256 balanceTo,
        euint256 amount,
        euint256 totalSupply
    ) internal returns (ebool success, euint256 newBalanceTo, euint256 newTotalSupply) {
        (bytes32 _success, bytes32 _newBalanceTo, bytes32 _newTotalSupply) = _noxComputeContract()
            .mint(
                _resolveUndefinedHandle(euint256.unwrap(balanceTo), TEEType.Uint256),
                _resolveUndefinedHandle(euint256.unwrap(amount), TEEType.Uint256),
                _resolveUndefinedHandle(euint256.unwrap(totalSupply), TEEType.Uint256)
            );
        success = ebool.wrap(_success);
        newBalanceTo = euint256.wrap(_newBalanceTo);
        newTotalSupply = euint256.wrap(_newTotalSupply);
    }

    /**
     * @dev Atomically burns `amount` from `balanceFrom` and decreases `totalSupply` by `amount`.
     * Returns the new balance, new total supply, and whether the burn was successful.
     * The burn will fail if `balanceFrom < amount`.
     */
    function burn(
        euint256 balanceFrom,
        euint256 amount,
        euint256 totalSupply
    ) internal returns (ebool success, euint256 newBalanceFrom, euint256 newTotalSupply) {
        (bytes32 _success, bytes32 _newBalanceFrom, bytes32 _newTotalSupply) = _noxComputeContract()
            .burn(
                _resolveUndefinedHandle(euint256.unwrap(balanceFrom), TEEType.Uint256),
                _resolveUndefinedHandle(euint256.unwrap(amount), TEEType.Uint256),
                _resolveUndefinedHandle(euint256.unwrap(totalSupply), TEEType.Uint256)
            );
        success = ebool.wrap(_success);
        newBalanceFrom = euint256.wrap(_newBalanceFrom);
        newTotalSupply = euint256.wrap(_newTotalSupply);
    }

    // ============ PERMISSION MANAGEMENT ============

    /**
     * @dev Allows the use of value for the address account.
     * Silently skips public handles (they are already accessible by everyone).
     */
    function allow(ebool value, address account) internal {
        _allowIfNotPublic(ebool.unwrap(value), account);
    }

    /**
     * @dev Allows the use of value for the address account.
     * Silently skips public handles (they are already accessible by everyone).
     */
    function allow(euint16 value, address account) internal {
        _allowIfNotPublic(euint16.unwrap(value), account);
    }

    /**
     * @dev Allows the use of value for the address account.
     * Silently skips public handles (they are already accessible by everyone).
     */
    function allow(euint256 value, address account) internal {
        _allowIfNotPublic(euint256.unwrap(value), account);
    }

    /**
     * @dev Allows the use of value for the address account.
     * Silently skips public handles (they are already accessible by everyone).
     */
    function allow(eint16 value, address account) internal {
        _allowIfNotPublic(eint16.unwrap(value), account);
    }

    /**
     * @dev Allows the use of value for the address account.
     * Silently skips public handles (they are already accessible by everyone).
     */
    function allow(eint256 value, address account) internal {
        _allowIfNotPublic(eint256.unwrap(value), account);
    }

    /**
     * @dev Allows the use of value for this address (address(this)).
     * Silently skips public handles (they are already accessible by everyone).
     */
    function allowThis(ebool value) internal {
        _allowIfNotPublic(ebool.unwrap(value), address(this));
    }

    /**
     * @dev Allows the use of value for this address (address(this)).
     * Silently skips public handles (they are already accessible by everyone).
     */
    function allowThis(euint16 value) internal {
        _allowIfNotPublic(euint16.unwrap(value), address(this));
    }

    /**
     * @dev Allows the use of value for this address (address(this)).
     * Silently skips public handles (they are already accessible by everyone).
     */
    function allowThis(euint256 value) internal {
        _allowIfNotPublic(euint256.unwrap(value), address(this));
    }

    /**
     * @dev Allows the use of value for this address (address(this)).
     * Silently skips public handles (they are already accessible by everyone).
     */
    function allowThis(eint16 value) internal {
        _allowIfNotPublic(eint16.unwrap(value), address(this));
    }

    /**
     * @dev Allows the use of value for this address (address(this)).
     * Silently skips public handles (they are already accessible by everyone).
     */
    function allowThis(eint256 value) internal {
        _allowIfNotPublic(eint256.unwrap(value), address(this));
    }

    /**
     * @dev Allows the use of value by address account for this transaction.
     * Silently skips public handles (they are already accessible by everyone).
     */
    function allowTransient(ebool value, address account) internal {
        _allowTransientIfNotPublic(ebool.unwrap(value), account);
    }

    /**
     * @dev Allows the use of value by address account for this transaction.
     * Silently skips public handles (they are already accessible by everyone).
     */
    function allowTransient(euint16 value, address account) internal {
        _allowTransientIfNotPublic(euint16.unwrap(value), account);
    }

    /**
     * @dev Allows the use of value by address account for this transaction.
     * Silently skips public handles (they are already accessible by everyone).
     */
    function allowTransient(euint256 value, address account) internal {
        _allowTransientIfNotPublic(euint256.unwrap(value), account);
    }

    /**
     * @dev Allows the use of value by address account for this transaction.
     * Silently skips public handles (they are already accessible by everyone).
     */
    function allowTransient(eint16 value, address account) internal {
        _allowTransientIfNotPublic(eint16.unwrap(value), account);
    }

    /**
     * @dev Allows the use of value by address account for this transaction.
     * Silently skips public handles (they are already accessible by everyone).
     */
    function allowTransient(eint256 value, address account) internal {
        _allowTransientIfNotPublic(eint256.unwrap(value), account);
    }

    /**
     * @dev Revokes transient access to value for address account within the current transaction.
     * Silently skips public handles (they are already accessible by everyone).
     */
    function disallowTransient(ebool value, address account) internal {
        _disallowTransientIfNotPublic(ebool.unwrap(value), account);
    }

    /**
     * @dev Revokes transient access to value for address account within the current transaction.
     * Silently skips public handles (they are already accessible by everyone).
     */
    function disallowTransient(euint16 value, address account) internal {
        _disallowTransientIfNotPublic(euint16.unwrap(value), account);
    }

    /**
     * @dev Revokes transient access to value for address account within the current transaction.
     * Silently skips public handles (they are already accessible by everyone).
     */
    function disallowTransient(euint256 value, address account) internal {
        _disallowTransientIfNotPublic(euint256.unwrap(value), account);
    }

    /**
     * @dev Revokes transient access to value for address account within the current transaction.
     * Silently skips public handles (they are already accessible by everyone).
     */
    function disallowTransient(eint16 value, address account) internal {
        _disallowTransientIfNotPublic(eint16.unwrap(value), account);
    }

    /**
     * @dev Revokes transient access to value for address account within the current transaction.
     * Silently skips public handles (they are already accessible by everyone).
     */
    function disallowTransient(eint256 value, address account) internal {
        _disallowTransientIfNotPublic(eint256.unwrap(value), account);
    }

    /**
     * @dev Checks if the handle is allowed for the account.
     */
    function isAllowed(ebool handle, address account) internal view returns (bool) {
        return _noxComputeContract().isAllowed(ebool.unwrap(handle), account);
    }

    /**
     * @dev Checks if the handle is allowed for the account.
     */
    function isAllowed(euint16 handle, address account) internal view returns (bool) {
        return _noxComputeContract().isAllowed(euint16.unwrap(handle), account);
    }

    /**
     * @dev Checks if the handle is allowed for the account.
     */
    function isAllowed(euint256 handle, address account) internal view returns (bool) {
        return _noxComputeContract().isAllowed(euint256.unwrap(handle), account);
    }

    /**
     * @dev Checks if the handle is allowed for the account.
     */
    function isAllowed(eint16 handle, address account) internal view returns (bool) {
        return _noxComputeContract().isAllowed(eint16.unwrap(handle), account);
    }

    /**
     * @dev Checks if the handle is allowed for the account.
     */
    function isAllowed(eint256 handle, address account) internal view returns (bool) {
        return _noxComputeContract().isAllowed(eint256.unwrap(handle), account);
    }

    // ============ VIEWER MANAGEMENT ============

    /**
     * @dev Adds a viewer for an ebool handle.
     */
    function addViewer(ebool value, address viewer) internal {
        _noxComputeContract().addViewer(ebool.unwrap(value), viewer);
    }

    /**
     * @dev Adds a viewer for an euint16 handle.
     */
    function addViewer(euint16 value, address viewer) internal {
        _noxComputeContract().addViewer(euint16.unwrap(value), viewer);
    }

    /**
     * @dev Adds a viewer for an euint256 handle.
     */
    function addViewer(euint256 value, address viewer) internal {
        _noxComputeContract().addViewer(euint256.unwrap(value), viewer);
    }

    /**
     * @dev Adds a viewer for an eint16 handle.
     */
    function addViewer(eint16 value, address viewer) internal {
        _noxComputeContract().addViewer(eint16.unwrap(value), viewer);
    }

    /**
     * @dev Adds a viewer for an eint256 handle.
     */
    function addViewer(eint256 value, address viewer) internal {
        _noxComputeContract().addViewer(eint256.unwrap(value), viewer);
    }

    /**
     * @dev Checks if the viewer can view the handle.
     */
    function isViewer(ebool handle, address viewer) internal view returns (bool) {
        return _noxComputeContract().isViewer(ebool.unwrap(handle), viewer);
    }

    /**
     * @dev Checks if the viewer can view the handle.
     */
    function isViewer(euint16 handle, address viewer) internal view returns (bool) {
        return _noxComputeContract().isViewer(euint16.unwrap(handle), viewer);
    }

    /**
     * @dev Checks if the viewer can view the handle.
     */
    function isViewer(euint256 handle, address viewer) internal view returns (bool) {
        return _noxComputeContract().isViewer(euint256.unwrap(handle), viewer);
    }

    /**
     * @dev Checks if the viewer can view the handle.
     */
    function isViewer(eint16 handle, address viewer) internal view returns (bool) {
        return _noxComputeContract().isViewer(eint16.unwrap(handle), viewer);
    }

    /**
     * @dev Checks if the viewer can view the handle.
     */
    function isViewer(eint256 handle, address viewer) internal view returns (bool) {
        return _noxComputeContract().isViewer(eint256.unwrap(handle), viewer);
    }

    // ============ PUBLIC DECRYPTION ============

    /**
     * @dev Marks an ebool handle as publicly decryptable.
     */
    function allowPublicDecryption(ebool value) internal {
        _noxComputeContract().allowPublicDecryption(ebool.unwrap(value));
    }

    /**
     * @dev Marks an euint16 handle as publicly decryptable.
     */
    function allowPublicDecryption(euint16 value) internal {
        _noxComputeContract().allowPublicDecryption(euint16.unwrap(value));
    }

    /**
     * @dev Marks an euint256 handle as publicly decryptable.
     */
    function allowPublicDecryption(euint256 value) internal {
        _noxComputeContract().allowPublicDecryption(euint256.unwrap(value));
    }

    /**
     * @dev Marks an eint16 handle as publicly decryptable.
     */
    function allowPublicDecryption(eint16 value) internal {
        _noxComputeContract().allowPublicDecryption(eint16.unwrap(value));
    }

    /**
     * @dev Marks an eint256 handle as publicly decryptable.
     */
    function allowPublicDecryption(eint256 value) internal {
        _noxComputeContract().allowPublicDecryption(eint256.unwrap(value));
    }

    /**
     * @dev Checks if the handle is publicly decryptable.
     */
    function isPubliclyDecryptable(ebool handle) internal view returns (bool) {
        return _noxComputeContract().isPubliclyDecryptable(ebool.unwrap(handle));
    }

    /**
     * @dev Checks if the handle is publicly decryptable.
     */
    function isPubliclyDecryptable(euint16 handle) internal view returns (bool) {
        return _noxComputeContract().isPubliclyDecryptable(euint16.unwrap(handle));
    }

    /**
     * @dev Checks if the handle is publicly decryptable.
     */
    function isPubliclyDecryptable(euint256 handle) internal view returns (bool) {
        return _noxComputeContract().isPubliclyDecryptable(euint256.unwrap(handle));
    }

    /**
     * @dev Checks if the handle is publicly decryptable.
     */
    function isPubliclyDecryptable(eint16 handle) internal view returns (bool) {
        return _noxComputeContract().isPubliclyDecryptable(eint16.unwrap(handle));
    }

    /**
     * @dev Checks if the handle is publicly decryptable.
     */
    function isPubliclyDecryptable(eint256 handle) internal view returns (bool) {
        return _noxComputeContract().isPubliclyDecryptable(eint256.unwrap(handle));
    }

    // ============ Public decryption proof verification ============

    /**
     * @dev Verifies a decryption proof and returns the decrypted boolean value.
     */
    function publicDecrypt(
        ebool handle,
        bytes calldata decryptionProof
    ) internal view returns (bool plaintextValue) {
        bytes memory result = _noxComputeContract().validateDecryptionProof(
            ebool.unwrap(handle),
            decryptionProof
        );
        require(result.length == 1, MalformedDecryptedData(result));
        require(result[0] == 0x00 || result[0] == 0x01, MalformedDecryptedData(result));
        return result[0] != 0x00;
    }

    /**
     * @dev Verifies a decryption proof and returns the decrypted uint16 value.
     */
    function publicDecrypt(
        euint16 handle,
        bytes calldata decryptionProof
    ) internal view returns (uint16 plaintextValue) {
        bytes memory result = _noxComputeContract().validateDecryptionProof(
            euint16.unwrap(handle),
            decryptionProof
        );
        require(result.length == 2, MalformedDecryptedData(result));
        return uint16(bytes2(result));
    }

    /**
     * @dev Verifies a decryption proof and returns the decrypted uint256 value.
     */
    function publicDecrypt(
        euint256 handle,
        bytes calldata decryptionProof
    ) internal view returns (uint256 plaintextValue) {
        bytes memory result = _noxComputeContract().validateDecryptionProof(
            euint256.unwrap(handle),
            decryptionProof
        );
        require(result.length == 32, MalformedDecryptedData(result));
        return uint256(bytes32(result));
    }

    /**
     * @dev Verifies a decryption proof and returns the decrypted int16 value.
     */
    function publicDecrypt(
        eint16 handle,
        bytes calldata decryptionProof
    ) internal view returns (int16 plaintextValue) {
        bytes memory result = _noxComputeContract().validateDecryptionProof(
            eint16.unwrap(handle),
            decryptionProof
        );
        require(result.length == 2, MalformedDecryptedData(result));
        return int16(uint16(bytes2(result)));
    }

    /**
     * @dev Verifies a decryption proof and returns the decrypted int256 value.
     */
    function publicDecrypt(
        eint256 handle,
        bytes calldata decryptionProof
    ) internal view returns (int256 plaintextValue) {
        bytes memory result = _noxComputeContract().validateDecryptionProof(
            eint256.unwrap(handle),
            decryptionProof
        );
        require(result.length == 32, MalformedDecryptedData(result));
        return int256(uint256(bytes32(result)));
    }

    // ============ Private helpers ============

    /**
     * @dev Resolves an undefined (bytes32(0)) handle to the typed zero handle for the given type.
     * If the handle is already non-zero, returns it unchanged.
     */
    function _resolveUndefinedHandle(
        bytes32 handle,
        TEEType teeType
    ) private view returns (bytes32) {
        return handle == bytes32(0) ? HandleUtils.zeroHandle(teeType) : handle;
    }
}


// File npm/@openzeppelin/contracts@5.6.1/utils/Context.sol

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


// File npm/@openzeppelin/contracts@5.6.1/access/Ownable.sol

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File contracts/NoxShare.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.27;


interface INoxShareToken {
    function mint(address to, externalEuint256 amount, bytes calldata proof) external;
    function balanceOf(address account) external view returns (bytes32);
}

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
     */
    function mintShare(address investor, externalEuint256 encryptedAmount, bytes calldata proof) public onlyOwner {
        shareToken.mint(investor, encryptedAmount, proof);
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

