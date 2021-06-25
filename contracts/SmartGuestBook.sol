// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SmartGuestBook is ERC721Enumerable, ERC721URIStorage {
    using Counters for Counters.Counter;

    struct Comment {
        address author;
        bytes32 hashedComment;
        string uri;
    }

    Counters.Counter private _commentId;

    mapping(uint256 => Comment) private _comments;

    event CommentLeaved(address indexed author, bytes32 indexed hashedComment);

    constructor() ERC721("Comment", "COM") {}

    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
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

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Enumerable, ERC721)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function comment(bytes32 hashedComment, string memory uri) public returns (uint256) {
        _commentId.increment();
        uint256 newCommentId = _commentId.current();
        _mint(msg.sender, newCommentId);
        _setTokenURI(newCommentId, uri);
        _comments[newCommentId] = Comment(msg.sender, hashedComment, uri);
        emit CommentLeaved(msg.sender, hashedComment);

        return newCommentId;
    }

    function dataOf(uint256 commentId) public view returns (Comment memory) {
        return _comments[commentId];
    }
}
