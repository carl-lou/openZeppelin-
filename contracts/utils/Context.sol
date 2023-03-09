// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * 提供有关当前执行上下文的信息，包括事务的发送方及其数据。而这些通常可以通过msg.调用者
 * 和msg.数据，它们不应该以这样直接的方式访问，
 * 因为在处理元事务时，发送和支付执行的帐户可能不是实际的发送者(就应用程序而言)。
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 此契约只适用于中间的类库契约。
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
