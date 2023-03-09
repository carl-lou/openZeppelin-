// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (crosschain/polygon/CrossChainEnabledPolygonChild.sol)

pragma solidity ^0.8.4;

import "../CrossChainEnabled.sol";
import "../../security/ReentrancyGuard.sol";
import "../../utils/Address.sol";
import "../../vendor/polygon/IFxMessageProcessor.sol";

address constant DEFAULT_SENDER = 0x000000000000000000000000000000000000dEaD;

/**
https://polygon.technology/[Polygon]专门化或{CrossChainEnabled}抽象子端(Polygon /mumbai)。
 * @dev https://polygon.technology/[Polygon] specialization or the
 * {CrossChainEnabled} abstraction the child side (polygon/mumbai).
 *
 这个版本应该只部署在子链上，以处理来自父链的跨链消息。
 * This version should only be deployed on child chain to process cross-chain
 * messages originating from the parent chain.
 *
 fxChild契约由多边形团队提供和维护。您可以在
 https://docs.polygon.technology/docs/develop/l1-l2-communication/fx-portal/#contract-addresses[polygon的Fx-Portal文档]中
 找到该合同多边形和孟买的地址。
 * The fxChild contract is provided and maintained by the polygon team. You can
 * find the address of this contract polygon and mumbai in
 * https://docs.polygon.technology/docs/develop/l1-l2-communication/fx-portal/#contract-addresses[Polygon's Fx-Portal documentation].
 *
 * _Available since v4.6._
 */
abstract contract CrossChainEnabledPolygonChild is IFxMessageProcessor, CrossChainEnabled, ReentrancyGuard {
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    address private immutable _fxChild;
    address private _sender = DEFAULT_SENDER;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address fxChild) {
        // 仅在构造函数中可修改
        _fxChild = fxChild;
    }

    /**
     * @dev see {CrossChainEnabled-_isCrossChain}
     */
    function _isCrossChain() internal view virtual override returns (bool) {
        // 调用者只能是 _fxChild地址，该地址在构造函数的时候定义后就不能修改了
        return msg.sender == _fxChild;
    }

    /**
     * @dev see {CrossChainEnabled-_crossChainSender}

     onlyCrossChain修饰符就是 判断了 调用者地址只能是_fxChild
     */
    function _crossChainSender() internal view virtual override onlyCrossChain returns (address) {
        return _sender;
    }

    /**
    接收和中继来自fxChild的消息的外部入口点。
     * @dev External entry point to receive and relay messages originating
     * from the fxChild.
     *
     不可重入性对于避免跨链调用能够通过使用用户定义的参数循环来模拟任何人是至关重要的。
     * Non-reentrancy is crucial to avoid a cross-chain call being able
     * to impersonate anyone by just looping through this with user-defined
     * arguments.
     *
     如果_fxChild调用任何其他做委托调用的函数，那么安全性可能会受到损害。
     * Note: if _fxChild calls any other function that does a delegate-call,
     * then security could be compromised.
     */
    function processMessageFromRoot(
        uint256, /* stateId */
        address rootMessageSender,
        bytes calldata data
    ) external override nonReentrant {
        // 如果不是跨链。报错
        if (!_isCrossChain()) revert NotCrossChainCall();

        _sender = rootMessageSender;
        // 委托调用，使用该合约的
        Address.functionDelegateCall(address(this), data, "cross-chain execution failed");
        _sender = DEFAULT_SENDER;
    }
}
