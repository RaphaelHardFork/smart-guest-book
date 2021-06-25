const { ethers } = require('hardhat')
const hre = require('hardhat')
const { deployed } = require('./deployed')

const CONTRACT_NAME = 'SmartGuestBook'

const main = async () => {
  const [deployer] = await ethers.getSigners()
  console.log('Deploying contracts with the account:', deployer.address)
  const SmartGuestBook = await hre.ethers.getContractFactory(CONTRACT_NAME)
  const smartGuestBook = await SmartGuestBook.deploy()
  await smartGuestBook.deployed()
  await deployed(CONTRACT_NAME, hre.network.name, smartGuestBook.address)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })

// npx hardhat run scripts/SmartGuestBook-deploy.js --network rinkeby
