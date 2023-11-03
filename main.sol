// SPDX-License-Identifier: MIT
//BioNTech, Sinovac, Moderna, GSK, Sanofi, AstraZeneca, Bavarian Nordic
pragma solidity ^0.8.18;


contract companyReg{

    struct company{
        string name;
        uint8 rating;
        bool registered;
        bytes20 UA;
        uint8 qControl;
        uint8 MFacility;
        uint8 ReguCompliance;
    }
   
    string public status;
    mapping(string => company) private registeredCompany;

    function setRating(string memory _name, uint8 _qControl, uint8 _MFacility, uint8 _ReguCompliance) private pure returns(company memory){
        uint8 _rating = (_qControl+_MFacility+_ReguCompliance)/3;
        require(_rating > 5, "Low rating! improve quality.");

        company memory newCompany = company({
            name: _name,
            rating: _rating,
            registered: false,
            UA:"",
            qControl: _qControl,
            MFacility: _MFacility,
            ReguCompliance: _ReguCompliance
        });
        return newCompany;
    }
    // bytes20 public truncatedHash;
    function regCompany(string memory _name, uint8 _qControl, uint8 _MFacility, uint8 _ReguCompliance) public returns(string memory)
    {
        company memory newCompany = setRating(_name, _qControl, _MFacility, _ReguCompliance);

        if (registeredCompany[_name].registered) {
            return status = "Company already registered.";
        }
        else 
        {
            string memory hashValue = string.concat(_name, toString(newCompany.rating));
            bytes32 messageHash = keccak256(bytes(hashValue));
            bytes20 truncatedHash = bytes20(messageHash);
            newCompany.registered = true;
            newCompany.UA = truncatedHash;
            registeredCompany[_name] = newCompany;
            return status = "Company registered successfully.";
        }
    }

    function checkRegCompany(string memory _name) public view returns(bool)
    {
        // status = "";
        if(registeredCompany[_name].registered)
        {
            return true;
        }
        else {
            return false;
        }
    }

    function getCompanyUA(string memory _name) public view returns(bytes20)
    {
        require(registeredCompany[_name].registered, "Company not registered");
        return registeredCompany[_name].UA;   
    }

    function toString(uint8 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
 
        uint8 temp = value;
        uint8 digits;
 
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
 
        bytes memory buffer = new bytes(digits);
 
        while (value != 0) {
            digits--;
            buffer[digits] = bytes1(uint8(48 + (value % 10)));
            value /= 10;
        }
 
        return string(buffer);
    }

}

contract vaccineReg{

    companyReg public contractA;

    constructor() {
        contractA = new companyReg();
    }

    function checkAvailability(string memory _name) public view returns(bool)
    {
        return contractA.checkRegCompany(_name);
    }
}
