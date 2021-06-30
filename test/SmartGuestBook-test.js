/* eslint-disable comma-dangle */
const { expect } = require('chai')
const { ethers } = require('hardhat')

describe('SmartGuestBook', function () {
  let SmartGuestBook, smartGuestBook, dev, author1, buyer
  const NAME = 'Comment'
  const SYMBOL = 'COM'
  const HASHED_COMMENT = ethers.utils.id('salut ton site est genial')
  const CID = 'QmZg7MTxjfgV54H2ZHZreqEnSAbcxaepLGYAaWAN6Ershh'
  const PRICE = ethers.utils.parseEther('0.1')
  const ZERO_ADDRESS = ethers.constants.AddressZero

  beforeEach(async function () {
    ;[dev, author1, buyer] = await ethers.getSigners()
    SmartGuestBook = await ethers.getContractFactory('SmartGuestBook')
    smartGuestBook = await SmartGuestBook.connect(dev).deploy()
    await smartGuestBook.deployed()
  })

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
        .comment(HASHED_COMMENT, CID)
    })

    it('Should increase the balance of the author', async function () {
      expect(await smartGuestBook.balanceOf(author1.address)).to.equal(1)
    })

    it('Should have the right owner', async function () {
      expect(await smartGuestBook.ownerOf(1)).to.equal(author1.address)
    })

    it('should have the right CID', async function () {
      expect(await smartGuestBook.tokenURI(1)).to.equal(CID)
    })

    it('Should emit a CommentLeaved event', async function () {
      expect(commentCall)
        .to.emit(smartGuestBook, 'CommentLeaved')
        .withArgs(author1.address, HASHED_COMMENT, CID, 1)
    })
  })

  describe('Delete a comment', function () {
    beforeEach(async function () {
      await smartGuestBook.connect(author1).comment(HASHED_COMMENT, CID)
    })

    it('should revert if not the moderator call the function', async function () {
      await expect(
        smartGuestBook.connect(author1).deleteComment(1)
      ).to.be.revertedWith('AccessControl:')
    })

    it('should delete the comment', async function () {
      await smartGuestBook.connect(dev).deleteComment(1)
      expect(await smartGuestBook.totalSupply()).to.equal(0)
    })

    it('should emit a CommentDeleted event', async function () {
      const hashedComment = await smartGuestBook.dataOf(1)
      expect(await smartGuestBook.connect(dev).deleteComment(1))
        .to.emit(smartGuestBook, 'CommentDeleted')
        .withArgs(dev.address, hashedComment.hashedComment, 1)
    })
  })

  describe('Selling tokens', function () {
    let sellCall
    beforeEach(async function () {
      await smartGuestBook.connect(author1).comment(HASHED_COMMENT, CID)
      sellCall = await smartGuestBook.connect(author1).sellComment(1, PRICE)
    })

    it('should approve contract for this token', async function () {
      expect(await smartGuestBook.getApproved(1)).to.equal(
        smartGuestBook.address
      )
    })

    it('should emit a CommentInSale event', async function () {
      expect(sellCall)
        .to.emit(smartGuestBook, 'CommentInSale')
        .withArgs(author1.address, 1, PRICE)
    })

    it('should can remove token from sale', async function () {
      await smartGuestBook.connect(author1).removeFromSale(1)
      expect(await smartGuestBook.getApproved(1)).to.equal(ZERO_ADDRESS)
    })

    it('should emit a CommentRemovedFromSale event when token removed from sale', async function () {
      expect(await smartGuestBook.connect(author1).removeFromSale(1))
        .to.emit(smartGuestBook, 'CommentRemovedFromSale')
        .withArgs(author1.address, 1)
    })

    it('should buy the token', async function () {
      await smartGuestBook.connect(buyer).buyComment(1, { value: PRICE })
      expect(await smartGuestBook.ownerOf(1)).to.equal(buyer.address)
    })

    it('should emit a CommentBought after the buy', async function () {
      expect(
        await smartGuestBook.connect(buyer).buyComment(1, { value: PRICE })
      )
        .to.emit(smartGuestBook, 'CommentBought')
        .withArgs(author1.address, buyer.address, 1, PRICE)
    })

    it('should revert if the value send is to low', async function () {
      await expect(
        smartGuestBook.connect(buyer).buyComment(1, { value: PRICE.div(2) })
      ).to.be.revertedWith('SmartGuestBook: value too low to buy this token.')
    })

    it('should refund if the value for the token is too high', async function () {
      expect(
        await smartGuestBook
          .connect(buyer)
          .buyComment(1, { value: PRICE.mul(3) })
      ).to.changeEtherBalance(buyer, PRICE.mul(-1))
    })
  })
})
