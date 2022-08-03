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

    PayMe = await ethers.getContractFactory("PaymentSplitter");  
    TVAF = await ethers.getContractFactory("VinnyandFrens");

    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    //Deploy
    PayMe = await PayMe.deploy([owner.address, addr1.address], ["60", "40"]);
    await PayMe.deployed();

    TVAF = await TVAF.deploy("", PayMe.address);
    await TVAF.deployed();

  });

  describe("Verify Initialization", function () {
    it("Verify 100 NFT Supply", async function () {
        expect(await TVAF.totalSupply()).to.equal(100);      
      });

    });

  describe("Whitelist Mint", function () {
    it("Whitelist mint 2 NFTs", async function () {
        await TVAF.addWhitelist([addr1.address, owner.address, addr2.address]);
        //Mint Test Tokens
        let overrides = {value: ethers.utils.parseEther("0.15598")};
        await TVAF.connect(addr1).mint(2, overrides);

        expect(await TVAF.totalSupply()).to.equal(102);  
    });
  });

  describe("Mint 69 NFTs", function () {
    it("Mint 69 NFTs", async function () {
        await TVAF.updatePhase();
        //Mint Test Tokens
        let overrides = {value: ethers.utils.parseEther("5.38131")};        
        await TVAF.connect(addr2).mint(69, overrides);

        expect(await TVAF.totalSupply()).to.equal(169);  
    });
  });

  describe("Verify Payment Splitter", function () {
    it("Payment Splitter", async function () {
        await TVAF.updatePhase();
        let contractBalance = await provider.getBalance(TVAF.address);
        expect(contractBalance).to.equal(ethers.utils.parseEther("0"));          
        //Mint Test Tokens
        let overrides = {value: ethers.utils.parseEther("1.01387")};        
        await TVAF.connect(addr2).mint(13, overrides);

        expect(await TVAF.totalSupply()).to.equal(113);  
        contractBalance = await provider.getBalance(TVAF.address);
        expect(contractBalance).to.equal(ethers.utils.parseEther("1.01387"));
        expect(await provider.getBalance(owner.address)).to.equal(ethers.utils.parseEther("9999.972554605175161615"));  
        expect(await provider.getBalance(addr1.address)).to.equal(ethers.utils.parseEther("9999.843890622817050496"));  
        // Should do a 60/40 split
        await TVAF.withdraw();
        contractBalance = await provider.getBalance(TVAF.address);        
        expect(contractBalance).to.equal(ethers.utils.parseEther("0"));  

        expect(await provider.getBalance(PayMe.address)).to.equal(ethers.utils.parseEther("1.01387"));
        await PayMe.release(owner.address);

        // RECEIVED 0.60826544098 ETH
        expect(await provider.getBalance(owner.address)).to.equal(ethers.utils.parseEther("10000.588510586545201703"));  
        // RECEIVED 0.40554799999 ETH
        expect(await provider.getBalance(addr1.address)).to.equal(ethers.utils.parseEther("10000.24942717338537984"));  
    });
  });
});
