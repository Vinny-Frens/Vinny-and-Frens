// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9 <0.9.0;

 /*  _     _      _     _      _     _      _     _      _     _     &     _     _      _     _      _     _      _     _      _     _   
  (c).-.(c)    (c).-.(c)    (c).-.(c)    (c).-.(c)    (c).-.(c)         (c).-.(c)    (c).-.(c)    (c).-.(c)    (c).-.(c)    (c).-.(c)  
   / ._. \      / ._. \      / ._. \      / ._. \      / ._. \           / ._. \      / ._. \      / ._. \      / ._. \      / ._. \   
 __\( Y )/__  __\( Y )/__  __\( Y )/__  __\( Y )/__  __\( Y )/__       __\( Y )/__  __\( Y )/__  __\( Y )/__  __\( Y )/__  __\( Y )/__ 
(_.-/'-'\-._)(_.-/'-'\-._)(_.-/'-'\-._)(_.-/'-'\-._)(_.-/'-'\-._)     (_.-/'-'\-._)(_.-/'-'\-._)(_.-/'-'\-._)(_.-/'-'\-._)(_.-/'-'\-._)
   || V ||      || I ||      || N ||      || N ||      || Y ||           || F ||      || R ||      || E ||      || N ||      || S ||   
 _.' `-' '._  _.' `-' '._  _.' `-' '._  _.' `-' '._  _.' `-' '._       _.' `-' '._  _.' `-' '._  _.' `-' '._  _.' `-' '._  _.' `-' '._ 
(.-./`-'\.-.)(.-./`-'\.-.)(.-./`-'\.-.)(.-./`-'\.-.)(.-./`-'\.-.)     (.-./`-'\.-.)(.-./`-`\.-.)(.-./`-'\.-.)(.-./`-'\.-.)(.-./`-`\.-.)
 `-'     `-'  `-'     `-'  `-'     `-'  `-'     `-'  `-'     `-'       `-'     `-'  `-'     `-'  `-'     `-'  `-'     `-'  `-'     `-' 
Lead Dev Jaz with help from devs 0xZoom, Doyler and Stinky */

import 'erc721a/contracts/extensions/ERC721AQueryable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/Strings.sol';


contract VinnyProposed is ERC721AQueryable, Ownable, ReentrancyGuard {

  using Strings for uint256;

  bytes32 public merkleRoot;
  mapping(address => bool) public whitelistClaimed;

  string public uriPrefix = '';
  string public uriSuffix = '.json';
  string public hiddenMetadataUri = '';
  
  uint256 public cost = 0.07799 ether;
  uint256 public maxSupply = 7799;
  uint256 public maxMintAmountPerTx = 42;
  uint256 public maxWalletSize = 70;

  bool public paused = true;
  bool public whitelistMintEnabled = false;
  bool public revealed = false;

  constructor(
    string memory _tokenName,
    string memory _tokenSymbol,
    uint256 _cost,
    uint256 _maxSupply,
    uint256 _maxMintAmountPerTx,
    uint256 _maxWalletSize,
    string memory _hiddenMetadataUri
  ) ERC721A(_tokenName, _tokenSymbol) {
    setCost(_cost);
    maxSupply = _maxSupply;
    setMaxMintAmountPerTx(_maxMintAmountPerTx);
    setMaxWalletSize(_maxWalletSize);
    setHiddenMetadataUri(_hiddenMetadataUri);
    //to mint at contract deployment. Enter address and qty to mint (replace 1)
    _mint(address (0xd40ebdb64C6A4445ab6a3361cbeF77Eb9d32b78c), 100);
        
   
  }

  //Checks for correct mint data being passed through
  modifier mintCheck(uint256 _mintAmount) {
    require(_mintAmount > 0 && _mintAmount <= maxMintAmountPerTx, 'Invalid mint amount!');
    require(totalSupply() + _mintAmount <= maxSupply, 'Max supply exceeded!');
    require(balanceOf(msg.sender) + _mintAmount <= maxWalletSize, 'Too many NFTs in this wallet!');
    _;
  }
  //Checks for correct mint pricing data being passed through
  modifier mintPriceCheck(uint256 _mintAmount) {
    require(msg.value >= cost * _mintAmount, 'Insufficient funds!');
    _;
  }
  //Whitelist minting
  function whitelistMint(uint256 _mintAmount, bytes32[] calldata _merkleProof) public payable mintCheck(_mintAmount) mintPriceCheck(_mintAmount) {
    // Checks whether the mint is open, whether an address has already claimed, and that they are on the WL
    require(whitelistMintEnabled, 'The whitelist sale is not enabled!');
    require(!whitelistClaimed[_msgSender()], 'Address already claimed!');
    bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
    require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), 'Invalid proof!');

    whitelistClaimed[_msgSender()] = true;
    _mint(_msgSender(), _mintAmount);
  }
  
  //Public minting
  function mint(uint256 _mintAmount) public payable mintCheck(_mintAmount) mintPriceCheck(_mintAmount) {
    require(!paused, 'The contract is paused!');

    _mint(_msgSender(), _mintAmount);
  }
  
  //Airdrop function - sends enetered number of NFTs to an address for free. Can only be called by Owner
  function airdrop(uint256 _mintAmount, address _receiver) public mintCheck(_mintAmount) onlyOwner {
    _mint(_receiver, _mintAmount);
  }

  //Starts token numbers from 1 rather than 0
  function _startTokenId() internal view virtual override returns (uint256) {
    return 1;
  }

  //return URI for a token based on whether collection is revealed or not
  function tokenURI(uint256 _tokenId) public view virtual override(ERC721A) returns (string memory) {
    require(_exists(_tokenId), 'ERC721Metadata: URI query for nonexistent token');

    if (revealed == false) {
      return hiddenMetadataUri;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix))
        : '';
  }

  //Reveal Collection  -true or false
  function setRevealed(bool _state) public onlyOwner {
    revealed = _state;
  }

  //Change token cost
  function setCost(uint256 _cost) public onlyOwner {
    cost = _cost;
  }

  //Change max amount of tokens por txn
  function setMaxMintAmountPerTx(uint256 _maxMintAmountPerTx) public onlyOwner {
    maxMintAmountPerTx = _maxMintAmountPerTx;
  }

  //Change max amount of tokens per wallet
  function setMaxWalletSize(uint256 _maxWalletSize) public onlyOwner {
    maxWalletSize = _maxWalletSize;
  }

  //set hidden metadata URI
  function setHiddenMetadataUri(string memory _hiddenMetadataUri) public onlyOwner {
    hiddenMetadataUri = _hiddenMetadataUri;
  }

  //set revealed URI prefix eg. ipfs://QmYW4a3Y--Yrs1JvhKzWzpTG2oF/
  function setUriPrefix(string memory _uriPrefix) public onlyOwner {
    uriPrefix = _uriPrefix;
  }

  //set revealed URI suffix eg. .json
  function setUriSuffix(string memory _uriSuffix) public onlyOwner {
    uriSuffix = _uriSuffix;
  }

  //function to pause the contract
  function setPaused(bool _state) public onlyOwner {
    paused = _state;
  }

  //function to set the merkle root
  function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
    merkleRoot = _merkleRoot;
  }

  //function to enable the white list mint
  function setWhitelistMintEnabled(bool _state) public onlyOwner {
    whitelistMintEnabled = _state;
  }
  
 function withdraw() public onlyOwner nonReentrant {

    (bool hs, ) = payable(0xd40ebdb64C6A4445ab6a3361cbeF77Eb9d32b78c).call{value: address(this).balance * 60/ 100}('');
    require(hs);

    (bool os, ) = payable(0xDf911FaA8a87700111b64F2ad5B9dBE25CEf47F9).call{value: address(this).balance}('');
    require(os);
  }

  //for emergency withdrawl if there is a problem with the payment splitter. You can remove this.
  function justInCase() public onlyOwner nonReentrant {
    
    (bool os, ) = payable(owner()).call{value: address(this).balance}('');
    require(os);
    
  }

  //update maxsupply to decrease colecton size if needed
  function updateMaxSupply(uint256 _newSupply) external onlyOwner {
        require(_newSupply < maxSupply, "You tried to increase the suppply. Decrease only.");
        maxSupply = _newSupply;
  }


  function _baseURI() internal view virtual override returns (string memory) {
    return uriPrefix;
  }

  
}
