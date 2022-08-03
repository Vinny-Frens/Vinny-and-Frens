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
});
