// SPDX-License-Identifier: MIT
//Vaccine Manufacturers - BioNTech, Sinovac, Moderna, GSK, Sanofi, AstraZeneca, Bavarian Nordic
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
            return status = string.concat(_name, " already registered.");
        }
        else 
        {
            string memory hashValue = string.concat(_name, toString(newCompany.rating));
            bytes32 messageHash = keccak256(bytes(hashValue));
            bytes20 truncatedHash = bytes20(messageHash);
            newCompany.registered = true;
            newCompany.UA = truncatedHash;
            registeredCompany[_name] = newCompany;
            return status = string.concat(_name, " registered successfully.");
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

    companyReg private companyreg;
    mapping(string=>string[]) public vaccineData;
    mapping(string=>string[]) public distData;
    mapping(string=>string[]) public pharmacyData;

    constructor(address _contract1) {
        companyreg = companyReg(_contract1);
    }

    function checkCompany(string memory _name) public view returns(bool)
    {
        return companyreg.checkRegCompany(_name);
    }

    function vacApplication(string memory _company, string memory _vaccine, uint8 _standard) public returns(string memory)
    {
        require(checkCompany(_company), string.concat(_company, " is not registered."));
        require(_standard>5, string.concat(_company, "'s Vaccine standard is low."));
        vaccineData[_vaccine].push(_company);
        return string.concat(_vaccine, " registered successfully.");   
    }

    function vaccineDistribution (string memory _vaccine, string memory _distributor, string memory _pharmacy) public returns(bool)
    {
        distData[_vaccine].push(_distributor);
        pharmacyData[_vaccine].push(_pharmacy);
        return true;
    }

    function vaccineStatus(string memory _vaccine) public view returns(bool)
    {
        if(vaccineData[_vaccine].length>0)
        {
            return true;
        }
        else {
            return false;
        }
    }

    function getDetails(string memory _vaccine) public view returns(string memory, string memory, string memory){
        return (vaccineData[_vaccine][0], distData[_vaccine][0], pharmacyData[_vaccine][0]);
    }
}

contract getVaccineData{

    vaccineReg private vaccinereg;

    constructor(address _contract2)
    {
        vaccinereg = vaccineReg(_contract2);
    }

    struct vaccine{
        string name;
        bool approved;
        string manufacturing_Date;
        string expiry_Date;
        string company;
        string distributor;
        string pharmacy;
    }

    // mapping(string=>vaccine) private vaccineData;

    function getVaccineDetails(string memory _vaccine) public view returns(vaccine memory)
    {
        require(vaccinereg.vaccineStatus(_vaccine), string.concat(_vaccine, " is not available;"));
        (string memory result1, string memory result2, string memory result3) = vaccinereg.getDetails(_vaccine);
        vaccine memory newVaccine = vaccine({
            name: _vaccine,
            approved: true,
            manufacturing_Date: "05/11/2023",
            expiry_Date: "05/11/2024",
            company: result1,
            distributor: result2,
            pharmacy: result3
        });
        return newVaccine;
    }

}
