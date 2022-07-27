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

    IERC20Upgradeable public paymentToken;

    enum State {
        Activated,
        Deactivated
    }

    struct Course{
        uint256 courseId;
        uint256 price;
        uint256 fprice;
        address owner;
        address fractionalToken;
        State state;
    }

    struct certificate {
      uint256 courseId;
      address candidate;
      string grade;
      uint256 timestamp;
  }

    event CourseCreated(
        uint256 courseId,
        uint256 price,
        address facilitator
    );

    event FractionalTokenPurchased(
        uint256 tokenId,
        uint256 price,
        address indexed user
    );

    event EDCUTokenPurchased(
        uint256 price,
        address indexed user
    );

    event CourseEnroll(
        uint256 courseId,
        address indexed user
    );

    event PaymentTokenUpdated(address indexed paymentToken);

    mapping(uint256 => Course) public Courses;

    mapping(uint256 => uint256) public tokenPrices;

    mapping(address => uint256[]) public userToCourseId;

    mapping(address => bool) public purchased;

    modifier notAddress0(address _address) {
        require(_address != address(0), "Address 0 is not allowed");
        _;
    }

    /// @notice Contract initializer
    function initialize(address _edcu, address _paymentToken)
        public
        initializer
    {
        __ERC721_init("Axyz Learning Management System", "AXYZ");
        __AccessControl_init();
        __UUPSUpgradeable_init();
        EDCUToken = IERC20Upgradeable(_edcu);
        paymentToken = IERC20Upgradeable(_paymentToken);
         _courseId.increment();
        _grantRole("Admin", msg.sender);

    }


    /**
     * @notice Authorizes upgrade allowed to only proxy 
     * @param newImplementation the address of the new implementation contract 
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyRole("Admin"){}


    function updatePaymentToken(address _token)
        external  notAddress0(_token)
    {
        paymentToken = IERC20Upgradeable(_token);
        emit PaymentTokenUpdated(_token);
    }


    function purchaseFToken(uint courseId)external{
        Course memory course = Courses[courseId];
        IERC20Upgradeable(paymentToken).safeTransferFrom(msg.sender, address(this), course.price);
        //IERC20Upgradeable(fnft.fractionalToken).mint(msg.sender, 10 ether);

        emit FractionalTokenPurchased(courseId, course.price, msg.sender);
    }


    function purchaseEDCUToken(uint _amount) external{
        uint price = tokenPrices[_amount];
        IERC20Upgradeable(paymentToken).safeTransferFrom(msg.sender, address(this), _amount);
        EDCUToken.safeTransfer(msg.sender, price);

        emit EDCUTokenPurchased(price, msg.sender);
    }


    function TokenEnroll(uint courseId, bool isEDCU)external{
        require(!purchased[msg.sender], "Course already purchased");
        require(isCourseActive(courseId), "course not enrollable");
        
        if(!isEDCU){
           Course memory course = Courses[courseId];
           //IERC20Upgradeable(course.fractionalToken).burn(msg.sender, course.fprice); 
        }
        else{
            EDCUToken.safeTransferFrom(msg.sender, address(this), Courses[courseId].price);
        }
        purchased[msg.sender] = true;
        userToCourseId[msg.sender].push(courseId);

        emit CourseEnroll(courseId, msg.sender);
    }

    function getCertificate(address _user)external{}

    function createCourse(
        uint price,
        string memory _name,
        string memory _code
    ) external{
        uint256 newTokenId = _courseId.current();
        _safeMint(msg.sender, newTokenId);

        //Create a ERC20 Token Contract for this newly minted NFT
        FractionalToken _fnftoken = new FractionalToken(_name, _code);                                     
        Courses[newTokenId]  = Course({
            courseId: newTokenId,
            price: price,
            fprice: 10 ether,
            owner: msg.sender,
            fractionalToken: address(_fnftoken),
            state: State.Activated
        }); 

        _courseId.increment();

        emit CourseCreated(newTokenId, price,  msg.sender);
    }


    function isCourseActive(uint256 courseId) public view returns(bool){
        Course memory course = Courses[courseId];

        if(course.state == State.Activated) return true;

        return false;
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