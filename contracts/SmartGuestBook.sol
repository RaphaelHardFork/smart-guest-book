// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract SmartGuestBook is ERC721Enumerable, ERC721URIStorage, AccessControl {
    using Address for address payable;
    using Counters for Counters.Counter;

    struct Comment {
        address author;
        bytes32 hashedComment;
        uint256 tokenId;
        string cid;
    }

    bytes32 private constant _MODERATOR_ROLE = keccak256("MODERATOR_ROLE");
    Counters.Counter private _commentId;
    mapping(uint256 => Comment) private _comments;
    mapping(uint256 => uint256) private _price; //OWNER PUT IN SALE HIS TOKEN
    //mapping(address => mapping(uint256 => uint256)) private _offer; //BUYER MAKE AN OFFER

    event CommentLeaved(address indexed author, bytes32 indexed hashedComment, string cid, uint256 tokenId);
    event CommentDeleted(address indexed moderator, bytes32 indexed hashedComment, uint256 tokenId);

    /* //BUYER MAKE AN OFFER
    event OfferForComment(address indexed bider, address indexed tokenOwner, uint256 tokenId, uint256 price);
    event OfferCancelled(address indexed bider, address indexed tokenOwner, uint256 tokenId, uint256 price);
    */

    //OWNER PUT IN SALE HIS TOKEN
    event CommentInSale(address indexed seller, uint256 tokenId, uint256 price);
    event CommentRemovedFromSale(address indexed seller, uint256 tokenId);
    event CommentBought(address indexed seller, address indexed buyer, uint256 tokenId, uint256 price);

    constructor() ERC721("Comment", "COM") {
        _setupRole(_MODERATOR_ROLE, msg.sender);
    }

    function comment(bytes32 hashedComment, string memory cid) public returns (uint256) {
        _commentId.increment();
        uint256 newCommentId = _commentId.current();
        _mint(msg.sender, newCommentId);
        _setTokenURI(newCommentId, cid);
        _comments[newCommentId] = Comment(msg.sender, hashedComment, newCommentId, cid);
        emit CommentLeaved(msg.sender, hashedComment, cid, newCommentId);

        return newCommentId;
    }

    function deleteComment(uint256 tokenId) public onlyRole(_MODERATOR_ROLE) returns (bool) {
        bytes32 hashedComment = dataOf(tokenId).hashedComment;
        _burn(tokenId);
        emit CommentDeleted(msg.sender, hashedComment, tokenId);
        return true;
    }

    /* //BUYER MAKE AN OFFER
    function makeOffer(uint256 tokenId) public payable returns (uint256) {
        _offer[msg.sender][tokenId] = msg.value;
        emit OfferForComment(msg.sender, ownerOf(tokenId), tokenId, msg.value);
        return msg.value;
    }

    function cancelOffer(uint256 tokenId) public returns (bool) {
        require(_offer[msg.sender][tokenId] != 0, "SmartGuestBook: you don't made offer for this token.");
        uint256 offer = _offer[msg.sender][tokenId];
        _offer[msg.sender][tokenId] = 0;
        payable(msg.sender).sendValue(offer);
        emit OfferCancelled(msg.sender, ownerOf(tokenId), tokenId, offer);
        return true;
    }

    function acceptOffer(uint256 tokenId, address bider) public returns (bool) {
        uint256 offer = _offer[bider][tokenId];
        _offer[msg.sender][tokenId] = 0;
        transferFrom(msg.sender, bider, tokenId);
        payable(msg.sender).sendValue(offer);
        return true;
    }

    function offerForFrom(uint256 tokenId, address bider) public view returns (uint256) {
        return _offer[bider][tokenId];
    }
    */

    //OWNER PUT IN SALE HIS TOKEN
    function sellComment(uint256 tokenId, uint256 price) public returns (uint256) {
        approve(address(this), tokenId);
        _price[tokenId] = price;
        emit CommentInSale(msg.sender, tokenId, price);
        return price;
    }

    function removeFromSale(uint256 tokenId) public returns (bool) {
        approve(address(0), tokenId);
        _price[tokenId] = 0;
        emit CommentRemovedFromSale(msg.sender, tokenId);
        return true;
    }

    function buyComment(uint256 tokenId) public payable returns (bool) {
        require(msg.value >= _price[tokenId], "SmartGuestBook: value too low to buy this token.");
        uint256 rest = msg.value - _price[tokenId];
        address owner = ownerOf(tokenId);
        payable(owner).sendValue(_price[tokenId]);
        _transfer(ownerOf(tokenId), msg.sender, tokenId);
        payable(msg.sender).sendValue(rest);
        emit CommentBought(owner, msg.sender, tokenId, _price[tokenId]);
        return true;
    }

    function inSale(uint256 tokenId) public view returns (uint256) {
        return _price[tokenId];
    }

    function dataOf(uint256 commentId) public view returns (Comment memory) {
        return _comments[commentId];
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Enumerable, ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _burn(uint256 tokenId) internal virtual override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}
