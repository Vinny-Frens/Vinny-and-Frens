// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

 /*  _     _      _     _      _     _      _     _      _     _     &     _     _      _     _      _     _      _     _      _     _   
  (c).-.(c)    (c).-.(c)    (c).-.(c)    (c).-.(c)    (c).-.(c)         (c).-.(c)    (c).-.(c)    (c).-.(c)    (c).-.(c)    (c).-.(c)  
   / ._. \      / ._. \      / ._. \      / ._. \      / ._. \           / ._. \      / ._. \      / ._. \      / ._. \      / ._. \   
 __\( Y )/__  __\( Y )/__  __\( Y )/__  __\( Y )/__  __\( Y )/__       __\( Y )/__  __\( Y )/__  __\( Y )/__  __\( Y )/__  __\( Y )/__ 
(_.-/'-'\-._)(_.-/'-'\-._)(_.-/'-'\-._)(_.-/'-'\-._)(_.-/'-'\-._)     (_.-/'-'\-._)(_.-/'-'\-._)(_.-/'-'\-._)(_.-/'-'\-._)(_.-/'-'\-._)
   || V ||      || I ||      || N ||      || N ||      || Y ||           || F ||      || R ||      || E ||      || N ||      || S ||   
 _.' `-' '._  _.' `-' '._  _.' `-' '._  _.' `-' '._  _.' `-' '._       _.' `-' '._  _.' `-' '._  _.' `-' '._  _.' `-' '._  _.' `-' '._ 
(.-./`-'\.-.)(.-./`-'\.-.)(.-./`-'\.-.)(.-./`-'\.-.)(.-./`-'\.-.)     (.-./`-'\.-.)(.-./`-`\.-.)(.-./`-'\.-.)(.-./`-'\.-.)(.-./`-`\.-.)
 `-'     `-'  `-'     `-'  `-'     `-'  `-'     `-'  `-'     `-'       `-'     `-'  `-'     `-'  `-'     `-'  `-'     `-'  `-'     `-' 
*/

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./ERC721A/ERC721A.sol";

/// Contract @title Vinny and Frens
contract VinnyandFrens is ERC721A, Ownable, Pausable {
    /// @notice Max Supply of Frens (immutable)
    uint256 public immutable maxSupply = 7799;
    /// @notice NFT Mint Price
    uint256 public mintPrice = .07799 ether;
    // If you are on the list, you can mint early
    mapping(address => uint256) public whitelist;     
    /// @notice Dev Wallet
    address private beneficiary;
    /// @notice NFT's Base Token URI
    string private baseTokenUri;
    /// @notice Is Minting Whitelist or Main mint
    bool public isWhitelist;

    error EmptyBalance();
    error IncorrectAmount();
    error InvalidQuantity();
    error MintedOut();
    error NotWhitelisted();

    /// @notice Deploy ERC-721A contract and initialize some values
    /// @param _tokenURI The initial global TokenURI
    /// @param benef The developer address
    constructor(string memory _tokenURI, address benef) ERC721A("Vinny and Frens", "VAF") {
        baseTokenUri = _tokenURI;
        //Mint 100 at deployment? to Deployer wallet?
        _mint(_msgSender(), 100);
        beneficiary = benef;
        isWhitelist = true;
    }

    /// External

    ///@notice Add an multiple addresses to the whitelist
    ///@param _whitelist array of addresses
    function addWhitelist(address[] memory _whitelist) external onlyOwner {
        for (uint i = 0; i < _whitelist.length; i++) {
            whitelist[_whitelist[i]] = 5;
          }
    }

    /// @notice Main Mint function
    /// @param _quantity How many mints would you like?
    function mint(uint256 _quantity) external payable whenNotPaused {
        if(_quantity < 1) { revert InvalidQuantity(); }
        if(totalSupply() + _quantity >= maxSupply) { revert MintedOut(); }
        if(msg.value < mintPrice) { revert IncorrectAmount(); }
        // If Phase is Whitelist, you must be on the list AND mint must be 2 or less
        if(isWhitelist) {
            if(_quantity > 5) { revert InvalidQuantity(); }
            if(!whitelist[_msgSender()]) { revert NotWhitelisted(); }
            whitelist[_msgSender()] -= _quantity;
        }
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
 
    /// @notice Turn ON/OFF the whitelist Phase
    function updatePhase() external onlyOwner {
        isWhitelist = !isWhitelist;
    }

    /// @notice Withdraw funds payment split between Art and Devs
     function withdraw() external onlyOwner {
         if(address(this).balance <= 0) { revert EmptyBalance(); }
         payable(beneficiary).transfer(address(this).balance);
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
