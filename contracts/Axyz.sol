// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
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
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter private _courseId;

    IERC20Upgradeable public EDCUToken;

    struct Course{
        uint256 courseId;
        uint256 price;
        address fractionalToken;
    }

    event CourseCreated(
        uint256 courseId,
        uint256 price,
        address facilitator
    );

    event FractionalTokenPurchased(
        uint256 tokenId,
        uint256 price,
        address indexed beneficiary
    );

    event EDCUTokenPurchased(
        uint256 price,
        address indexed beneficiary
    );

    mapping(uint256 => Course) public Courses;

    mapping(uint256 => uint256) public tokenPrices;


    /// @notice Contract initializer
    function initialize(address _edcu)
        public
        initializer
    {
        __ERC721_init("Axyz Learning Management System", "AXYZ");
        __AccessControl_init();
        __UUPSUpgradeable_init();
        EDCUToken = IERC20Upgradeable(_edcu);
         _courseId.increment();
        _grantRole("Admin", msg.sender);

    }


    /**
     * @notice Authorizes upgrade allowed to only proxy 
     * @param newImplementation the address of the new implementation contract 
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyRole("Admin"){}

    function purchaseFToken(uint courseId, address _token)external{
        Course memory course = Courses[courseId];
        IERC20Upgradeable(_token).safeTransferFrom(msg.sender, address(this), course.price);
        //IERC20Upgradeable(fnft.fractionalToken).mint(msg.sender, 10 ether);

        emit FractionalTokenPurchased(courseId, course.price, msg.sender);
    }

    function purchaseEDCUToken(uint _amount, address _token) external{
        uint price = tokenPrices[_amount];
        IERC20Upgradeable(_token).safeTransferFrom(msg.sender, address(this), _amount);
        EDCUToken.safeTransfer(msg.sender, price);

        emit EDCUTokenPurchased(price, msg.sender);
    }

    function NFTEnroll(uint courseId)external{

    }

    function TokenEnroll()external{}

    function getCertificate(address _user)external{}

    function createCourse(
        address _to,
        uint price,
        string memory _name,
        string memory _code
    ) external{
        uint256 newTokenId = _courseId.current();
        _safeMint(_to, newTokenId);

        //Create a ERC20 Token Contract for this newly minted NFT
        FractionalToken _fnftoken = new FractionalToken(_name, _code);                                     
        Course memory course;                                                        
        course.courseId = newTokenId;                           
        course.fractionalToken = address(_fnftoken);
        course.price = price;
        Courses[newTokenId]  = course; 

        _courseId.increment();

        emit CourseCreated(newTokenId, price,  _to);
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