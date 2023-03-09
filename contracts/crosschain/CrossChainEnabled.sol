// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (crosschain/CrossChainEnabled.sol)

pragma solidity ^0.8.4;

import "./errors.sol";

/**
提供构建跨链感知合约的信息。当接收跨链消息时，这个抽象契约提供了访问器和修饰符来控制执行流。
 * @dev Provides information for building cross-chain aware contracts. This
 * abstract contract provides accessors and modifiers to control the execution
 * flow when receiving cross-chain messages.
 *
 基于这种抽象的跨链感知契约的实际实现将不得不从特定于桥的专门化继承。
 这样的专门化在' crosschain/<chain>/CrossChainEnabled<chain>.sol '下提供。
 * Actual implementations of cross-chain aware contracts, which are based on
 * this abstraction, will  have to inherit from a bridge-specific
 * specialization. Such specializations are provided under
 * `crosschain/<chain>/CrossChainEnabled<chain>.sol`.
 *
 * _Available since v4.6._
 */
abstract contract CrossChainEnabled {
    /**
    如果当前函数调用不是跨链执行的结果，则抛出错误
     * @dev Throws if the current function call is not the result of a
     * cross-chain execution.
     */
    modifier onlyCrossChain() {
        // NotCrossChainCall 是在errors.sol文件里定义的error
        if (!_isCrossChain()) revert NotCrossChainCall();
        _;
    }

    /**
    如果当前函数调用不是由' account '发起的跨链执行的结果，则报错
     * @dev Throws if the current function call is not the result of a
     * cross-chain execution initiated by `account`.
     */
    modifier onlyCrossChainSender(address expected) {
        address actual = _crossChainSender();
        if (expected != actual) revert InvalidCrossChainSender(actual, expected);
        _;
    }

    /**
     * @dev Returns whether the current function call is the result of a
     * cross-chain message.
     */
    function _isCrossChain() internal view virtual returns (bool);

    /**
    返回触发当前函数调用的跨链消息的发送者的地址。
     * @dev Returns the address of the sender of the cross-chain message that
     * triggered the current function call.
     *
     重要提示:如果当前函数调用不是跨链消息的结果，应该使用' NotCrossChainCall '恢复回滚。
     * IMPORTANT: Should revert with `NotCrossChainCall` if the current function
     * call is not the result of a cross-chain message.
     */
    function _crossChainSender() internal view virtual returns (address);
}
