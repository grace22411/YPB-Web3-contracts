// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

contract LMS is 
Initializable,
UUPSUpgradeable,
OwnableUpgradeable, 
ReentrancyGuardUpgradeable {
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;


    /// @notice Contract initializer
    function initialize()
        public
        initializer
    {
        __Ownable_init();

    }


    /**
     * @notice Authorizes upgrade allowed to only proxy 
     * @param newImplementation the address of the new implementation contract 
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner{}

    function purchaseToken()external{}

    function NFTEnroll()external{}

    function TokenEnroll()external{}

    function getCertificate(address _user)external{}

    function createCourse()external{}
    
}