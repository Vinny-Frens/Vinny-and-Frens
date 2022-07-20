// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./ERC721A/ERC721A.sol";

contract TVAF is ERC721A, Ownable, Pausable {
    using Counters for Counters.Counter;

    // @notice Counter for number of minted characters
    Counters.Counter public _tokenIds;    
    // Max Supply of DegenDwarfs
    uint256 public immutable maxSupply = 100;
    uint256 public mintPrice;
    address private artWallet;
    address private devWallet;
    string private _baseTokenUri;     

    constructor(string memory _tokenURI, address _dev, address _art) ERC721A("The Vinnie And Frens", "TVAF") {
        _baseTokenUri = _tokenURI;
        //Mint 100 at deployment? to Deployer wallet?
        _mint(_msgSender(), 100);
        mintPrice = 0.01 ether;
        devWallet = _dev;
        artWallet = _art;

    }

    function mint(uint256 _quantity) external payable {
        require(msg.value == mintPrice, "Invalid Balance");
        _mint(_msgSender(), _quantity);
    }

    function withdraw() external onlyOwner {
        uint256 artPay = (address(this).balance * (1e18 - 0.6 ether)) / 1e18;
        uint256 devPay = (address(this).balance * (1e18 - 0.4 ether)) / 1e18;
        //Add logic
        payable(artWallet).transfer(artPay);
        payable(devWallet).transfer(devPay);
    }

    function updatePrice(uint256 _newPrice) external onlyOwner {
        mintPrice = _newPrice;
    }
 
    function setBaseURI(string memory baseURI) external onlyOwner {
        _baseTokenUri = baseURI;
    }  

    function pauseMinting() external onlyOwner {
        _pause();
    }

    function unpauseMinting() external onlyOwner {
        _unpause();
    }  
   
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return string(abi.encodePacked(_baseURI(), toString(tokenId), ".json"));
    }

    function toString(uint256 value) internal pure returns (string memory) {
    // Inspired by OraclizeAPI's implementation - MIT license
    // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol
        if (value == 0) {
            return "0";
        }

        uint256 temp = value;
        uint256 digits;

        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);

        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }

        return string(buffer);
    }
}