// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract companyReg{

    struct company{
        string name;
        uint8 rating;
        bool registered;
        string UA;
        uint8 qControl;
        uint8 MFacility;
        uint8 ReguCompliance;
    }
    string public ans;
    
    mapping(string => company) public registeredCompany;

    function setRating(string memory _name, uint8 _qControl, uint8 _MFacility, uint8 _ReguCompliance) public returns(string memory){
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


        if (registeredCompany[_name].registered) {
            return "Company already registered.";
        }
        else 
        {
            newCompany.registered = true;
            newCompany.UA = "abc";
            registeredCompany[_name] = newCompany;
            return "Company sucessfully registered.";
        }

        string storage ans = setRating(_name, _qControl, _MFacility, _ReguCompliance);
    }
}