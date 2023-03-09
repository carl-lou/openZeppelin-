// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/presets/ERC20PresetFixedSupply.sol)
pragma solidity ^0.8.0;

import "../extensions/ERC20Burnable.sol";

/**
 * @dev {ERC20} token, including:
 *
 *  - Preminted initial supply 预估初始供应量
 *    持有者烧毁(销毁)他们的代币的能力
 *  - Ability for holders to burn (destroy) their tokens
 *    没有访问控制机制(用于创建/暂停)，因此没有治理
 *  - No access control mechanism (for minting/pausing) and hence no governance
 *  
 * 这个合约使用{ERC20Burnable}来包含燃烧功能——详情请参阅它的文档。
 * This contract uses {ERC20Burnable} to include burn capabilities - head to
 * its documentation for details.
 *
 * _Available since v3.4._
 *
 * _Deprecated in favor of https://wizard.openzeppelin.com/[Contracts Wizard]._
 */
contract ERC20PresetFixedSupply is ERC20Burnable {
    /**
     * 铸造' initialSupply '数量的令牌，并将它们转移到'所有者'。
     * @dev Mints `initialSupply` amount of token and transfers them to `owner`.
     *
     * See {ERC20-constructor}.
     */
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address owner
    ) ERC20(name, symbol) {
        _mint(owner, initialSupply);
    }
}
