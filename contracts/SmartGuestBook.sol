// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SmartGuestBook is ERC721Enumerable, ERC721URIStorage, AccessControl {
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

    event CommentLeaved(address indexed author, bytes32 indexed hashedComment, string cid, uint256 tokenId);
    event CommentDeleted(address indexed moderator, bytes32 indexed hashedComment, uint256 tokenId);

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
