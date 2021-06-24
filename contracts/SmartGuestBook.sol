// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SmartGuestBook is ERC721URIStorage {
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
