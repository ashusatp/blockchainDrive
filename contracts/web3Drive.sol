// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract web3Drive{

    struct Access{
        address user; 
        bool access;
    }

    // mapping with string array (user->ipfs_urls_of_images)
    mapping(address=>string[]) values;

    // mapping of owner of file to the users who have access
    mapping(address=> Access[]) accessList;

    // mapping of owner of file to the mapping of user have access or not (2D array)
    mapping(address=> mapping(address=>bool)) ownership;    
    mapping(address=> mapping(address=>bool)) previousData;

    function addURL(address user, string memory url) external {
        values[user].push(url);
    }

    function giveAccess(address user) external{
        ownership[msg.sender][user] = true;
        uint256 usersConnected = accessList[msg.sender].length; 
        for(uint256 i=0; i<usersConnected; i++){
            if(accessList[msg.sender][i].user == user){
                if(accessList[msg.sender][i].access == true){
                    return;
                }
                if(previousData[msg.sender][user]){
                    accessList[msg.sender][i].access = true;
                    previousData[msg.sender][user] = false;
                    return;
                }
            }
        }
        accessList[msg.sender].push(Access(user,true));
    }

    function removeAccess(address user) public{
        ownership[msg.sender][user] = false;
        uint256 usersConnected = accessList[msg.sender].length; 
        for(uint256 i=0; i<usersConnected; i++){
            if(accessList[msg.sender][i].user == user){
                accessList[msg.sender][i].access = false;
                previousData[msg.sender][user] = true;
            }
        }
    }

    function display(address user) external view returns(string[] memory){
        require(user == msg.sender || ownership[user][msg.sender], "you don't have access");
        return values[user];
    }

    function shareAccess() public view returns(Access[] memory){
        return accessList[msg.sender];
    }

}