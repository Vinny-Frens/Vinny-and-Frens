const { expect } = require("chai");
const { ethers, waffle } = require("hardhat");

describe("TVAF Contract", function () {
  let TVAF;
  let owner;
  let addr1;
  let addr2;
  let addrs;
  let provider;

  beforeEach(async function () {
    provider = waffle.provider;

    TVAF = await ethers.getContractFactory("TVAF");

    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    //Deploy Loans.sol
    TVAF = await TVAF.deploy("", owner.address, addr1.address);
    await TVAF.deployed();

  });

  describe("Verify Mint & PaymentSplitter", function () {
    it("Verify 100 NFT Supply", async function () {
        expect(await TVAF.totalSupply()).to.equal(100);      
      });

    it("Mint 10 NFTs", async function () {
        //Mint Test Tokens
        let overrides = {value: ethers.utils.parseEther("0.7799")};
        await TVAF.connect(addr1).mint(10, overrides);

        expect(await TVAF.totalSupply()).to.equal(110);  
    });

    it("Mint 69 NFTs", async function () {
        //Mint Test Tokens
        let overrides = {value: ethers.utils.parseEther("5.38131")};        
        await TVAF.connect(addr2).mint(69, overrides);

        expect(await TVAF.totalSupply()).to.equal(169);  
    });

    it("Payment Splitter", async function () {
        let contractBalance = await provider.getBalance(TVAF.address);
        expect(contractBalance).to.equal(ethers.utils.parseEther("0"));          
        //Mint Test Tokens
        let overrides = {value: ethers.utils.parseEther("1.01387")};        
        await TVAF.connect(addr2).mint(13, overrides);

        expect(await TVAF.totalSupply()).to.equal(113);  
        contractBalance = await provider.getBalance(TVAF.address);
        expect(contractBalance).to.equal(ethers.utils.parseEther("1.01387"));  
        expect(await provider.getBalance(owner.address)).to.equal(ethers.utils.parseEther("9999.981577527256849356"));  
        expect(await provider.getBalance(addr1.address)).to.equal(ethers.utils.parseEther("9999.219932892499184854"));  
        // Should do a 60/40 split
        await TVAF.withdraw();
        contractBalance = await provider.getBalance(TVAF.address);        
        expect(contractBalance).to.equal(ethers.utils.parseEther("0"));  
        // RECEIVED 0.60825992374 ETH
        expect(await provider.getBalance(owner.address)).to.equal(ethers.utils.parseEther("10000.589837451001976444"));  
        // RECEIVED 0.40554799999 ETH
        expect(await provider.getBalance(addr1.address)).to.equal(ethers.utils.parseEther("9999.625480892499184854"));  
    });
  });
});
