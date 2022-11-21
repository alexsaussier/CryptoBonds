// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

import "hardhat/console.sol";
import "./Ownable.sol";
import "./ethTransactions.sol";

/* 

TO DO LIST:

- Build Front end
- Build payment logic for:
    - Buying bonds (user pays to company address)
    - Paying coupons (company pays user)

- Deploy on test net and test functions / or use remix. Need to test:
    - Minting bond
    - Reselling bond
    - Bond id logic

    


*/

contract BondFactory is Ownable, ReceiveEther, SendEther{


    event NewBond(string _name, uint bondId, string enventName);

    modifier onlyOwnerOf(uint _bondId) {
        require(msg.sender == bondIdToOwner[_bondId]);
        _;
    }


    uint256 id = 0;
    mapping (uint => address) bondIdToOwner;

        
    mapping (address => string) addressToCompany;

    function createCompany(string memory _name, address payable _companyAddress) external {
        addressToCompany[_companyAddress] = _name;
    }


    struct Bond {
        address payable companyAdress;
        uint32 maxAmount;
        uint32 faceValue;
        uint32 interestRate;
        uint32 term; 
        string couponPaymentFrequency;
    }

        
    Bond[] internal bonds; //Array to store all emitted bonds

    //To determine how many bonds an address has
    mapping (address => uint) public ownerBondCount;
    

    //Creates a new bond struct instance
    function mintBond(address payable _companyAddress, uint32 _maxAmount, 
    uint32 _faceValue, uint32 _interestRate, uint32 _term, string memory _couponPaymentFrequency) 
            external {

        Bond memory newBond = Bond(_companyAddress, _maxAmount,
        _faceValue, _interestRate, _term, _couponPaymentFrequency);

        //store it in general bonds array
        bonds.push(newBond);

        bondIdToOwner[id] = msg.sender;
        ownerBondCount[msg.sender]++;
        
        string memory eventName = "New Bond was minted.";
        emit NewBond(addressToCompany[_companyAddress], id, eventName);
        id = id + 1;

        //Payment from lender to company. Need to set msg.value
        sendViaCall(_companyAddress);
    }



/*
    //This function should be called by the company from their portal
    function payCoupons(Company memory _company) external{
        require(msg.sender == _company.companyAddress);

        //iterate through all bonds issued by a company, and pay their owner
        for (uint32 i = 0; i <= _company.bondsIssuedByCompany.length; i++){
            sendViaCall(_company.bondIdToOwner[i]); //need to determine the amount / set msg.value
        }
        
    }
*/

    //Withdraw funds on this contract
    function withdraw() external onlyOwner {
    address payable _owner = payable(owner());
    _owner.transfer(address(this).balance);
    }

    function getAllBonds() internal view returns (Bond[] memory){
        return bonds;
    }

}