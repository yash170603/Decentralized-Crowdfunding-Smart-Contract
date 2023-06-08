// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Project {
    mapping(address => uint) public contributorsamount;
    address public manager;
    uint public target;
    uint public deadline;
    uint public minimum_contirbution;
    uint public raisedamount;
    uint public number_of_contributors;
    uint public numberofrequests;

    struct Request {
        string description;
        uint amountrequired;
        address payable reciepent;
        uint numberofvotes;
        bool votingdone;
        mapping(address => bool) voters;
    }

    mapping(uint => Request) public aboutrequest;

    constructor(uint _target, uint _deadline) {
        deadline = block.timestamp + _deadline;
        target = _target;
        minimum_contirbution = 100 wei;
        manager = msg.sender;
    }

    function sendeth() public payable {
        require(block.timestamp < deadline, "The deadline has occurred");
        require(msg.value >= minimum_contirbution, "The minimum contribution has not been met");

        if (contributorsamount[msg.sender] == 0) {
            number_of_contributors++;
        }
        contributorsamount[msg.sender] += msg.value;
        raisedamount += msg.value;
    }

    function getbalance() public view returns (uint) {
        return address(this).balance;
    }

    function refund() public {
        require(raisedamount < target || block.timestamp > deadline, "Refund is not allowed");
        require(contributorsamount[msg.sender] > 0, "Nothing to refund");

        address payable moneyholder = payable(msg.sender);
        moneyholder.transfer(contributorsamount[msg.sender]);
        contributorsamount[msg.sender] = 0;
    }

    modifier onlymanager() {
        require(msg.sender == manager, "Only manager can access this");
        _;
    }

    function createrequest(string memory _description, address payable _reciepent, uint _amountrequired) public onlymanager {
        Request storage REQUEST = aboutrequest[numberofrequests];
        numberofrequests++;
        REQUEST.description = _description;
        REQUEST.reciepent = _reciepent;
        REQUEST.amountrequired = _amountrequired;
        REQUEST.votingdone = false;
        REQUEST.numberofvotes = 0;
    }

    function voteRequest(uint _requestNo) public {
        require(contributorsamount[msg.sender] > 0, "You must be a contributor to vote");
        Request storage thisRequest = aboutrequest[_requestNo];
        require(thisRequest.voters[msg.sender] == false, "You have already voted for this request");
        thisRequest.voters[msg.sender] = true;
        thisRequest.numberofvotes++;
        if (thisRequest.numberofvotes == number_of_contributors) {
            thisRequest.votingdone = true;
        }
    }

    function recieveth(uint _requestNo) public onlymanager {
        require(raisedamount >= target, "Target amount not reached");
        Request storage thisRequest = aboutrequest[_requestNo];
        require(thisRequest.votingdone == true, "Voting for this request is not complete");
        require(thisRequest.numberofvotes > number_of_contributors / 2, "Not enough votes to approve this request");
        thisRequest.reciepent.transfer(thisRequest.amountrequired);
        thisRequest.votingdone = false;
        thisRequest.numberofvotes = 0;
    }
}
