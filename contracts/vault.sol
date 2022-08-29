// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

contract Vault{
    // a contract where the owner create grant for a beneficiary
    // allows the beneficiary to withdraw only when time elapses
    // allows owner to withdraw before time elapse
    // get information of a beneficiary
    // amount of ethers in the smart contract

    //*********state variables*******

    address public owner;
    uint ID=1;
    uint[] id;

    struct BeneficiaryProperties{
        uint amountAllocated;
        address beneficiary;
        uint time;
        bool status; // to get the status of the transaction ;
    }

    mapping(uint => BeneficiaryProperties) public _beneficiaryProperties;

    modifier onlyOwner(){
       require(msg.sender == owner, "not owner");
       _;

   }
   
   BeneficiaryProperties[] public bp;


   modifier hasTimeElaped(uint _id){
       BeneficiaryProperties memory BP = _beneficiaryProperties[_id];
       require(BP.time <= block.timestamp, "time never reach");
       require( block.timestamp >= BP.time, "time never reach");
       _;
   }

    constructor(){
        owner = msg.sender;
    }
   
    function createGrant(address _beneficiary, uint _time) external payable onlyOwner returns(uint){
        require(msg.value > 0, "zero ether not allowed");
        BeneficiaryProperties storage BP = _beneficiaryProperties[ID];
        BP.time = _time;
        BP.amountAllocated= msg.value;
        BP.beneficiary = _beneficiary;
        uint _id = ID;
        id.push(_id);
        // bp.push(BP)
        ID++;
        return _id;

    }

    //Assignment: write a withdraw function that allows the grant beneficiary to withdraw any amount he/she wants, 
    // not the predefined version we have now.
    //  Tip: There are some things you have to check.

    function withdraw(uint _id)external hasTimeElaped(_id){
        BeneficiaryProperties storage BP = _beneficiaryProperties[_id];
        address user = BP.beneficiary; // reading from the storage

        require(user == msg.sender, "not a beneficairy for a grant");
         uint _amount = BP.amountAllocated;
        require(_amount > 0,"this beneficiary has no money");
        uint getBal = getBalance();
        require(getBal >= _amount, "insfficient fund");
    
        BP.amountAllocated=0; //writing to the storage
        payable(user).transfer(_amount);
    }

    function RevertGrant(uint _id) external onlyOwner{
        BeneficiaryProperties storage BP = _beneficiaryProperties[_id];
        uint _amount = BP.amountAllocated;
        BP.amountAllocated=0;
        payable(owner).transfer(_amount);

    }

    function returnBeneficiaryInfo(uint _id)external view returns(BeneficiaryProperties memory BP){
        BP = _beneficiaryProperties[_id];
    }

    function getBalance() public view returns (uint256 bal){
        bal = address(this).balance;
    }
function getAllBeneficiary() external view returns (BeneficiaryProperties[] memory _bp){
      uint[] memory all = id;


        _bp = new BeneficiaryProperties[](all.length);

        for(uint i=0; i < all.length; i++){
            _bp[i]= _beneficiaryProperties[all[i]];
        }  
        
    }
  
}