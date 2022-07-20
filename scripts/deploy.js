const { getAddress } = require("ethers/lib/utils");

async function main() {
    if (network.name === "hardhat") {
      console.warn(
        "You are trying to deploy a contract to the Hardhat Network, which" +
          "gets automatically created and destroyed every time. Use the Hardhat" +
          " option '--network localhost'"
      );
    }
  
    const [deployer] = await ethers.getSigners();
  
    console.log(
      "Deploying the contracts with the account:",
      await deployer.getAddress()
    );

    console.log("Account balance:", (await deployer.getBalance()).toString());
    TVAF = await ethers.getContractFactory("VinnyandFrens");

    //Deploy TVAF.sol
    TVAF = await TVAF.deploy("", deployer.getAddress(), deployer.getAddress());
    await TVAF.deployed();
    console.log("VinnyandFrens contract Deployed");    

    saveFrontendFiles();
}

function saveFrontendFiles() {
    const fs = require("fs");
    const contractsDir = __dirname + "";
  
    if (!fs.existsSync(contractsDir)) {
      fs.mkdirSync(contractsDir);
    }
  
    fs.writeFileSync(
      contractsDir + "/abi/contract-addresses.json",
      JSON.stringify({ VinnyandFrens: TVAF.address}, undefined, 2)
    );
  
    TVAFArtifact = artifacts.readArtifactSync("VinnyandFrens");
  
    fs.writeFileSync(
      contractsDir + "/abi/VinnyandFrens.json",
      JSON.stringify(TVAFArtifact, null, 2)
    );
  
  }

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });