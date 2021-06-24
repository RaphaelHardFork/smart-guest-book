const { expect } = require('chai')
const { ethers } = require('hardhat')

describe('SmartGuestBook', function () {
  let SmartGuestBook, smartGuestBook, dev, author1
  const NAME = 'Comment'
  const SYMBOL = 'COM'
  const HASHED_COMMENT = ethers.utils.id('salut ton site est genial')
  const URI = 'https://ipfs.io'

  beforeEach(async function () {
    ;[dev, author1] = await ethers.getSigners()
    // ERC20 deployment
    SmartGuestBook = await ethers.getContractFactory('SmartGuestBook')
    smartGuestBook = await SmartGuestBook.connect(dev).deploy()
    await smartGuestBook.deployed()
  })

  // DEPLOYMENT
  describe('Deployment', function () {
    it('Should set name & symbol', async function () {
      expect(await smartGuestBook.name(), 'name').to.equal(NAME)
      expect(await smartGuestBook.symbol(), 'symbol').to.equal(SYMBOL)
    })
  })

  describe('Leave a comment', function () {
    let commentCall
    beforeEach(async function () {
      commentCall = await smartGuestBook
        .connect(author1)
        .comment(HASHED_COMMENT, URI)
    })

    it('Should increase the balance of the author', async function () {
      expect(await smartGuestBook.balanceOf(author1.address)).to.equal(1)
    })

    it('Should have the right owner', async function () {
      expect(await smartGuestBook.ownerOf(1)).to.equal(author1.address)
    })

    it('should have the right URI', async function () {
      expect(await smartGuestBook.tokenURI(1)).to.equal(URI)
    })

    it('Should emit a CommentLeaved event', async function () {
      expect(commentCall)
        .to.emit(smartGuestBook, 'CommentLeaved')
        .withArgs(author1.address, HASHED_COMMENT)
    })
  })
})
