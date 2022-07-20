// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./ERC721A/ERC721A.sol";

/// Contract @title The Vinnie And Frens
contract VinnyandFrens is ERC721A, Ownable, Pausable {
    /// @notice Max Supply of Frens (immutable)
    uint256 public immutable maxSupply = 7799;
    /// @notice NFT Mint Price
    uint256 public mintPrice = .07799 ether;
    /// @notice Artist Wallet
    address private artWallet;
    /// @notice Dev Wallet
    address private devWallet;
    /// @notice NFT's Base Token URI
    string private baseTokenUri;  

    error EmptyBalance();
    error IncorrectAmount();
    error InvalidQuantity();
    error MintedOut();

    /// @notice Deploy ERC-721A contract and initialize some values
    /// @param _tokenURI The initial global TokenURI
    /// @param _dev The developer address
    /// @param _art The artist address
    constructor(string memory _tokenURI, address _dev, address _art) ERC721A("The Vinnie And Frens", "TVAF") {
        baseTokenUri = _tokenURI;
        //Mint 100 at deployment? to Deployer wallet?
        _mint(_msgSender(), 100);
        devWallet = _dev;
        artWallet = _art;
    }

    /// External

    /// @notice Main Mint function
    /// @param _quantity How many mints would you like?
    function mint(uint256 _quantity) external payable whenNotPaused {
        if(_quantity < 1) { revert InvalidQuantity(); }
        if(totalSupply() + _quantity >= maxSupply) { revert MintedOut(); }
        if(msg.value < mintPrice) { revert IncorrectAmount(); }
        _mint(_msgSender(), _quantity);
    }

    /// @notice Update the base URI
    /// @param _baseURI The new base URI
    function setBaseURI(string memory _baseURI) external onlyOwner {
        baseTokenUri = _baseURI;
    }  
   
    /// @notice Returns the URI link for the metadata
    /// @param _tokenId Token ID
    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        return string(abi.encodePacked(_baseURI(), toString(_tokenId), ".json"));
    }

    /// @notice Update the Mint price
    /// @param _newPrice The new mint price
    function updatePrice(uint256 _newPrice) external onlyOwner {
        mintPrice = _newPrice;
    }
 
    /// @notice Withdraw funds payment split between Art and Devs
    function withdraw() external onlyOwner {
        if(address(this).balance <= 0) { revert EmptyBalance(); }
        uint256 artPay = (address(this).balance * (1e18 - 0.6 ether)) / 1e18;
        uint256 devPay = (address(this).balance * (1e18 - 0.4 ether)) / 1e18;
        //Add logic
        payable(artWallet).transfer(artPay);
        payable(devWallet).transfer(devPay);
    }

    /// Internal

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