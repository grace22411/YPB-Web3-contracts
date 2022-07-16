// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";



contract FractionalNFTToken is ERC20, Ownable{
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol){}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

/**
 * @title FractionalNFT
 * FractionalNFT - ERC721 contract that whitelists an address, and has minting functionality.
 */
contract FractionalNFT is ERC721URIStorage, Ownable {

    using Counters for Counters.Counter;
    using SafeMath for uint;

    Counters.Counter private _tokenIds;

    string public tokenName;
    string public tokenSymbol;

    struct _fnft{
        uint256 tokenId;
        address fractionalToken;
    }

    event Minted(
        uint256 tokenId,
        address beneficiary,
        string tokenUri,
        address minter
    );

    mapping(uint256 => _fnft) public FNFT;


    /// @notice Contract constructor
    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        tokenName = _name;
        tokenSymbol = _symbol;
        _tokenIds.increment();
    }


    /**
     * @dev Mints a token to an address with a tokenURI.
     * @param _to address of the future owner of the token
     * @param tokenURI_ uri of the token
     * @param _totalFractionalTokens number of fractional tokens per holder
     */
    function mint(address _to,
        string calldata  tokenURI_, 
        uint256 _totalFractionalTokens
    ) external{
        uint256 newTokenId = _tokenIds.current();
        _safeMint(_to, newTokenId);
        _setTokenURI(newTokenId, tokenURI_);

        //Create a ERC20 Token Contract for this newly minted NFT
        FractionalNFTToken _fnftoken = (new FractionalNFTToken)(tokenName, tokenSymbol);                                     
        _fnftoken.mint(msg.sender, _totalFractionalTokens.mul(1 ether));   
        _fnft memory fnft;                                                        
        fnft.tokenId = _tokenIds.current();                           
        fnft.fractionalToken = address(_fnftoken);
        FNFT[_tokenIds.current()]  = fnft; 

        _tokenIds.increment();

        emit Minted(newTokenId, _to, tokenURI_, _msgSender());
    }

}