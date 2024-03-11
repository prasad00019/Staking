const hre = require("hardhat");
async function main() {
    const MyContract = await ethers.getContractFactory("Staking");
    // some random address is used here 
    const tokenAddress = '0xaA42C3c8303B1A9B9ce5a1d128db836ebe2455e4'; 
    const myContract = await MyContract.deploy(tokenAddress);
    console.log("MyContract deployed to:", myContract.address);
    // Send the reserved tokens to the staking contract. 

}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });