// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/utils/TokenTimelock.sol)

pragma solidity ^0.8.0;

import "./SafeERC20.sol";

/**
 * 一种令牌持有者合同，允许受益人在给定的释放时间后提取令牌。 锁定 token一段时间
 * @dev A token holder contract that will allow a beneficiary to extract the
 * tokens after a given release time.
 *
 * 适用于简单的授予计划，如“顾问在1年后获得所有代币”。
 * Useful for simple vesting schedules like "advisors get all of their tokens
 * after 1 year".
 */
contract TokenTimelock {
    // 给IERC20赋予SafeERC20里的方法
    using SafeERC20 for IERC20;

    // immutable 表示不可变的（最多只能在构造函数里可以修改，
    // 其他时候该变量里储存的信息不可变）
    // ERC20 basic token contract being held
    // 正在持有的ERC20基本代币合约
    IERC20 private immutable _token;

    // beneficiary of tokens after they are released
    // 代币被释放后的受益人 地址
    address private immutable _beneficiary;

    // timestamp when token release is enabled
    // 启用令牌释放时的时间戳。解禁的时间
    uint256 private immutable _releaseTime;

    /**
     * 部署一个时间锁实例，该实例能够保存指定的令牌，
     * 并且只会在' releaseTime_ '之后调用{release}时将它释放给' benefary_ '。
     * 发布时间指定为Unix时间戳(以秒为单位)。
     * @dev Deploys a timelock instance that is able to hold the token specified, and will only release it to
     * `beneficiary_` when {release} is invoked after `releaseTime_`. The release time is specified as a Unix timestamp
     * (in seconds).
     */
    constructor(
        IERC20 token_,
        address beneficiary_,
        uint256 releaseTime_
    ) {
        // 解禁时间 要比部署时候的区块的时间晚
        require(releaseTime_ > block.timestamp, "TokenTimelock: release time is before current time");
        // 置入token对象
        _token = token_;
        _beneficiary = beneficiary_;
        _releaseTime = releaseTime_;
    }

    /**
     * @dev Returns the token being held.
     */
    function token() public view virtual returns (IERC20) {
        return _token;
    }

    /**
     * @dev Returns the beneficiary that will receive the tokens.
     */
    function beneficiary() public view virtual returns (address) {
        return _beneficiary;
    }

    /**
     * @dev Returns the time when the tokens are released in seconds since Unix epoch (i.e. Unix timestamp).
     */
    function releaseTime() public view virtual returns (uint256) {
        return _releaseTime;
    }

    /**
     * 将时间锁持有的代币转移给受益人。只有在发布时间之后调用才会成功。
     * @dev Transfers tokens held by the timelock to the beneficiary. Will only succeed if invoked after the release
     * time.
     */
    function release() public virtual {
        // 调用该函数的时候的区块时间需要 晚于 之前部署的时候设定的解禁时间
        require(block.timestamp >= releaseTime(), "TokenTimelock: current time is before release time");

        // address(this)指的是TokenTimelock合约的实例的地址
        // 获取当前合约地址在token()里的余额
        uint256 amount = token().balanceOf(address(this));
        require(amount > 0, "TokenTimelock: no tokens to release");

        // token()转给beneficiary一笔amount数额的token
        token().safeTransfer(beneficiary(), amount);
    }
}
