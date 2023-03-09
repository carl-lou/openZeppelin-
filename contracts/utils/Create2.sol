// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Create2.sol)

pragma solidity ^0.8.0;

/**
帮助使用' CREATE2 ' EVM操作码更容易和更安全。
 * @dev Helper to make usage of the `CREATE2` EVM opcode easier and safer.
 “CREATE2”可用于提前计算智能合约将部署的地址，这允许使用有趣的新机制，即“反事实交互”。
 * `CREATE2` can be used to compute in advance the address where a smart
 * contract will be deployed, which allows for interesting new mechanisms known
 * as 'counterfactual interactions'.
 *
 * See the https://eips.ethereum.org/EIPS/eip-1014#motivation[EIP] for more
 * information.
 */
library Create2 {
    /**
    使用create2部署合约，可以通过computeAddress提前获知合约地址
     * @dev Deploys a contract using `CREATE2`. The address where the contract
     * will be deployed can be known in advance via {computeAddress}.
     *
     合约的字节码可以通过“type(contractName). creationcode”从Solidity获得。
     * The bytecode for a contract can be obtained from Solidity with
     * `type(contractName).creationCode`.
     *
     * Requirements:
     *
     * - `bytecode` must not be empty.   bytecode必须不为空
     * - `salt` must have not been used for `bytecode` already.  盐必须没被字节码用过
     * - the factory must have a balance of at least `amount`.
     * - if `amount` is non-zero, `bytecode` must have a `payable` constructor.
     */
    function deploy(
        uint256 amount,
        bytes32 salt,
        bytes memory bytecode
    ) internal returns (address addr) {
        // 当前合约（工厂合约）的eth余额必须大于amount,amount是创建合约的时候用到的
        require(address(this).balance >= amount, "Create2: insufficient balance");
        // 字节码长度不能为0
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        /// @solidity memory-safe-assembly
        assembly {
            // create2的4个入参如下
            // endowment（创建合约时往合约中打的 ETH 数量）
            // memory_start（代码在内存中的起始位置，一般固定为 add(bytecode, 0x20) ）
            // memory_length（代码长度，一般固定为 mload(bytecode) ）
            // salt（随机数盐） 随机数盐是由用户自定，须为 bytes32 格式，例如在上面 Uniswap 的例子中，salt 为：bytes32 salt = keccak256(abi.encodePacked(token0, token1));
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        // 新合约的地址不能为0地址
        require(addr != address(0), "Create2: Failed on deploy");
    }

    /**
    返回通过{deploy}部署的合约存储地址。' bytecodeHash '或' salt '中的任何变化都将导致一个新的目标地址。
     * @dev Returns the address where a contract will be stored if deployed via {deploy}. Any change in the
     * `bytecodeHash` or `salt` will result in a new destination address.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {
        return computeAddress(salt, bytecodeHash, address(this));
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy} from a contract located at
     * `deployer`. If `deployer` is this contract's address, returns the same value as {computeAddress}.
     */
    function computeAddress(
        bytes32 salt,
        bytes32 bytecodeHash,
        address deployer
    ) internal pure returns (address addr) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40) // Get free memory pointer

            // |                   | ↓ ptr ...  ↓ ptr + 0x0B (start) ...  ↓ ptr + 0x20 ...  ↓ ptr + 0x40 ...   |
            // |-------------------|---------------------------------------------------------------------------|
            // | bytecodeHash      |                                                        CCCCCCCCCCCCC...CC |
            // | salt              |                                      BBBBBBBBBBBBB...BB                   |
            // | deployer          | 000000...0000AAAAAAAAAAAAAAAAAAA...AA                                     |
            // | 0xFF              |            FF                                                             |
            // |-------------------|---------------------------------------------------------------------------|
            // | memory            | 000000...00FFAAAAAAAAAAAAAAAAAAA...AABBBBBBBBBBBBB...BBCCCCCCCCCCCCC...CC |
            // | keccak(start, 85) |            ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ |

            mstore(add(ptr, 0x40), bytecodeHash)
            mstore(add(ptr, 0x20), salt)
            mstore(ptr, deployer) // Right-aligned with 12 preceding garbage bytes
            let start := add(ptr, 0x0b) // The hashed data starts at the final garbage byte which we will set to 0xff
            mstore8(start, 0xff)
            addr := keccak256(start, 85)
        }

        // 方法二：非汇编方式
        //  bytes32 _data = keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash));
        // return address(uint160(uint256(_data)));
    }
}
