// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./FractionalNFT.sol";

contract NFTFactory is Ownable {
  /// @dev Events of the contract
    event CourseCreated(address creator, address nft);
    event CourseDisabled(address creator, address nft);

    /// @notice NFT Address => Bool
    mapping(address => bool) public exists;

    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;
    

    /// @notice Method for deploy new FactionalNFT contract
    /// @param _name Name of NFT course
    /// @param _symbol Symbol of NFT course
    function createCourse(string memory _name, string memory _symbol)
        external
        returns (address)
    {
        FractionalNFT nft = new FractionalNFT(
            _name,
            _symbol
        );

        exists[address(nft)] = true;
        nft.transferOwnership(_msgSender());
        emit CourseCreated(_msgSender(), address(nft));
        return address(nft);
    }


    /// @notice Method for disabling existing FractionalNFT contract
    /// @param  courseAddress Address of NFT collection
    function disableCourse(address courseAddress)
        external
    {
        require(exists[courseAddress], "NFT contract is not registered");
        exists[courseAddress] = false;
        emit CourseDisabled(_msgSender(), courseAddress);
    }
}