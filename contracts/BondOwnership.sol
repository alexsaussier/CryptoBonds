// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

// Import this file to use console.log
import "hardhat/console.sol";
import "./ERC721.sol";
import "./BondFactory.sol";

// This contract determines the rules for buying/selling bonds
contract BondOwnership is BondFactory, ERC721{


    mapping (uint => address) bondApprovals;

    function balanceOf(address _owner) external view override returns (uint256) {
        return ownerBondCount[_owner];
    }

    function ownerOf(uint256 _tokenId) external view override returns (address) {
        return bondIdToOwner[_tokenId];
    }

    function _transfer(address _from, address _to, uint256 _tokenId) private {
        ownerBondCount[_to] = ownerBondCount[_to]+1;//need safemath for this
        ownerBondCount[_from] = ownerBondCount[_from]-1;
        bondIdToOwner[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable override {
        require (bondIdToOwner[_tokenId] == msg.sender || bondApprovals[_tokenId] == msg.sender);
        _transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) external payable override onlyOwnerOf(_tokenId) {
        bondApprovals[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }

}
