// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./FractionalToken.sol";

contract Axyz is 
Initializable,
UUPSUpgradeable,
AccessControlUpgradeable,
ReentrancyGuardUpgradeable,
ERC721URIStorageUpgradeable
 {
    using SafeMathUpgradeable for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter private _tokenId;

    struct _fnft{
        uint256 tokenId;
        address fractionalToken;
    }

    event CourseCreated(
        uint256 tokenId,
        address facilitator
    );

    mapping(uint256 => _fnft) public FNFT;


    /// @notice Contract initializer
    function initialize()
        public
        initializer
    {
        __ERC721_init("Axyz Learning Management System", "AXYZ");
        __AccessControl_init();
        __UUPSUpgradeable_init();
         _tokenId.increment();
        _grantRole("Admin", msg.sender);

    }


    /**
     * @notice Authorizes upgrade allowed to only proxy 
     * @param newImplementation the address of the new implementation contract 
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyRole("Admin"){}

    function purchaseToken()external{}

    function NFTEnroll()external{}

    function TokenEnroll()external{}

    function getCertificate(address _user)external{}

    function createCourse(
        address _to,
        string memory _name,
        string memory _code
    ) external{
        uint256 newTokenId = _tokenId.current();
        _safeMint(_to, newTokenId);

        //Create a ERC20 Token Contract for this newly minted NFT
        FractionalToken _fnftoken = (new FractionalToken)(_name, _code);                                     
        _fnft memory fnft;                                                        
        fnft.tokenId = _tokenId.current();                           
        fnft.fractionalToken = address(_fnftoken);
        FNFT[_tokenId.current()]  = fnft; 

        _tokenId.increment();

        emit CourseCreated(newTokenId, _to);
    }


    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
    
}