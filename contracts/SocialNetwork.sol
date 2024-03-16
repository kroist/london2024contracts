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
        int256 rating;
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

    error ProjectNotExisting(uint256 projectId);
    error CommentNotExisting(uint256 commentId);
    error NotSupported();

    address owner;

    Pass public pass;

    uint256 public projectsCount;
    uint256 public commentsCount;
    mapping(uint256 => Project) projects;
    mapping(uint256 => int256) projectRating;

    mapping(uint256 => address) projectAddress;
    mapping(uint256 => uint64) projectChainSelector;

    mapping(uint256 => uint256) projectDeposit;
    mapping(address => uint256) userDeposit;
    uint256 overallDeposit;

    mapping(uint256 => Comment) comments;
    mapping(uint256 => uint256) projectCommentsCount;
    mapping(uint256 => mapping(uint256 => uint256)) projectCommentsIds;

    address public router;

    constructor(
        address _passAddress,
        address _router
    ) {
        owner = msg.sender;
        pass = Pass(_passAddress);
        router = _router;
    }

    function getProjects() public view returns (Project[] memory) {
        Project[] memory arr = new Project[](projectsCount);
        for (uint256 i = 0; i < projectsCount; i++) {
            arr[i] = projects[i+1];
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
            url,
            0
        );
    }

    function getComments(uint256 projectId) public view returns (Comment[] memory) {
        uint256 commentCnt = projectCommentsCount[projectId];
        Comment[] memory arr = new Comment[](commentCnt);
        for (uint256 i = 0; i < commentCnt; i++) {
            arr[i] = comments[(projectCommentsIds[projectId])[i+1]];
        }
        return arr;
    }

    function addComment(uint256 projectId, bytes32 textHash) public hasPass returns (uint256) {
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
        return commentsCount;
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

    function changeProjectRating(uint256 projectId, int256 delta) public hasPass {
        require(delta == -1 || delta == 1, "|delta| = 1");
        Project memory proj = projects[projectId];
        if (proj.id == 0) {
            revert ProjectNotExisting(projectId);
        }
        projectRating[projectId] += delta;
        // maxRating
        // uint256 rating = projectRating[projectId] / 
        projects[projectId] = Project(proj.id, proj.name, proj.network, proj.url, proj.rating);
        emit NewRatingChange(proj.id, delta);
    }

    function setProjectChainInfo(uint256 projectId, uint64 chSelector, address addr) public onlyOwner {
        projectChainSelector[projectId] = chSelector;
        projectAddress[projectId] = addr;
    }

    bytes4 private constant SELECTOR = bytes4(keccak256(bytes("sendMessagePayLINK(uint64,address,string)")));

    function depositIntoPool(uint256 projectId, uint256 amount) public hasPass {
        uint64 chSelector = projectChainSelector[projectId];
        if (chSelector == 0) {
            revert NotSupported();
        }
        if (chSelector == 12532609583862916517) {
            /// deposit on same chain
            return;
        }
        string memory _text = string(abi.encode(msg.sender, amount));
        projectDeposit[projectId] += amount;
        overallDeposit += amount;
        router.call(abi.encodeWithSelector(SELECTOR, chSelector, projectAddress[projectId], _text));
    }

    modifier hasPass() {
        //TODO uncomment
        // require(pass.validatePass(msg.sender));
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

}