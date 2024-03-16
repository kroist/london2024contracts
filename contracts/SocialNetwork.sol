// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import './interface/ISemaphoreVerifier.sol';
import './Pass.sol';

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract SocialNetwork {

    struct Project {
        uint256 id;
        string name;
        string network;
        string url;
    }

    struct Comment {
        uint256 id;
        uint256 projectId;
        bytes32 textHash;
        int256 rating;
        address user;
    }

    event NewComment(uint256 projectId, address user, uint256 commentId);
    event NewRatingChange(uint256 commentId, int256 delta);

    error CommentNotExisting(uint256 commentId);

    address owner;

    Pass public pass;

    uint256 public projectsCount;
    uint256 public commentsCount;
    mapping(uint256 => Project) projects;
    mapping(uint256 => Comment) comments;
    mapping(uint256 => uint256) projectCommentsCount;
    mapping(uint256 => mapping(uint256 => uint256)) projectCommentsIds;

    constructor(
        address _passAddress
    ) {
        owner = msg.sender;
        pass = Pass(_passAddress);
    }

    function getProjects() public view returns (Project[] memory) {
        Project[] memory arr = new Project[](projectsCount);
        for (uint256 i = 0; i < projectsCount; i++) {
            arr[i] = projects[i];
        }
        return arr;
    }

    function addProject(
        string memory name,
        string memory network,
        string memory url
    ) public onlyOwner {
        ++projectsCount;
        projects[projectsCount] = Project(
            projectsCount,
            name,
            network,
            url
        );
    }

    function getComments(uint256 projectId) public view returns (Comment[] memory) {
        uint256 commentCnt = projectCommentsCount[projectId];
        Comment[] memory arr = new Comment[](commentCnt);
        for (uint256 i = 0; i < commentCnt; i++) {
            arr[i] = comments[(projectCommentsIds[projectId])[i]];
        }
        return arr;
    }

    function addComment(uint256 projectId, bytes32 textHash) public hasPass {
        commentsCount++;
        comments[commentsCount] = Comment(
            commentsCount,
            projectId,
            textHash,
            0,
            msg.sender
        );
        projectCommentsCount[projectId]++;
        projectCommentsIds[projectId][projectCommentsCount[projectId]] = commentsCount;
        emit NewComment(projectId, msg.sender, commentsCount);
    }

    function changeCommentRating(uint256 commentId, int256 delta) public hasPass {
        require(delta == -1 || delta == 1, "|delta| = 1");
        Comment memory com = comments[commentId];
        if (com.id == 0) {
            revert CommentNotExisting(commentId);
        }
        comments[commentId] = Comment(com.id, com.projectId, com.textHash, com.rating+delta, com.user);
        emit NewRatingChange(com.id, delta);
    }

    modifier hasPass() {
        require(pass.validatePass(msg.sender));
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

}