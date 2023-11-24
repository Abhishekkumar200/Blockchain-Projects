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

    function setRating(string memory _company, uint8 _qControl, uint8 _MFacility, uint8 _ReguCompliance) private pure returns(company memory){
        uint8 _rating = (_qControl+_MFacility+_ReguCompliance)/3;
        require(_rating > 5, "Low rating! improve quality.");

        company memory newCompany = company({
            name: _company,
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
    function regCompany(string memory _company, uint8 _qControl, uint8 _MFacility, uint8 _ReguCompliance) public returns(string memory)
    {
        company memory newCompany = setRating(_company, _qControl, _MFacility, _ReguCompliance);

        if (registeredCompany[_company].registered) {
            return status = string.concat(_company, " already registered.");
        }
        else 
        {
            string memory hashValue = string.concat(_company, toString(newCompany.rating));
            bytes32 messageHash = keccak256(bytes(hashValue));
            bytes20 truncatedHash = bytes20(messageHash);
            newCompany.registered = true;
            newCompany.UA = truncatedHash;
            registeredCompany[_company] = newCompany;
            return status = string.concat(_company, " registered successfully.");
        }
    }

    function checkRegCompany(string memory _company) public view returns(bool)
    {
        // status = "";
        if(registeredCompany[_company].registered)
        {
            return true;
        }
        else {
            return false;
        }
    }

    function getCompanyUA(string memory _company) public view returns(bytes20)
    {
        require(registeredCompany[_company].registered, "Company not registered");
        return registeredCompany[_company].UA;   
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

    mapping(string=>string[]) private vaccineData;
    mapping(string=>string[]) private distData;
    mapping(string=>string[]) private pharmacyData;
    mapping(string=>string[6]) private batchNo;

    constructor(address _contract1) {
        companyreg = companyReg(_contract1);
    }

    function checkCompany(string memory _company) public view returns(bool)
    {
        return companyreg.checkRegCompany(_company);
    }

    function vacApplication(string memory _company, string memory _vaccine, uint8 _standard) public returns(string memory)
    {
        require(checkCompany(_company), string.concat(_company, " is not registered."));
        require(_standard>5, string.concat(_company, "'s Vaccine standard is low."));
        vaccineData[_vaccine].push(_company);
        batchNo[_vaccine][1] = "24/11/23";
        batchNo[_vaccine][2] = "01/12/23";
        batchNo[_vaccine][3] = "02/12/23";
        batchNo[_vaccine][4] = "05/12/23";
        batchNo[_vaccine][5] = "10/12/23";
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

    function getDetails(string memory _vaccine, uint _batchNo) external view returns(string memory, string memory, string memory, string memory){
        return (vaccineData[_vaccine][0], distData[_vaccine][0], pharmacyData[_vaccine][0], batchNo[_vaccine][_batchNo]);
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
        uint batchNo;
        string distributor;
        string pharmacy;
    }

    // mapping(string=>vaccine) private vaccineData;

    function getVaccineDetails(string memory _vaccine, uint _batchNo) public view returns(vaccine memory)
    {
        require(vaccinereg.vaccineStatus(_vaccine), string.concat(_vaccine, " is not available;"));
        (string memory result1, string memory result2, string memory result3, string memory result4) = vaccinereg.getDetails(_vaccine, _batchNo);
        vaccine memory newVaccine = vaccine({
            name: _vaccine,
            approved: true,
            manufacturing_Date: result4,
            expiry_Date: "30/11/2024",
            company: result1,
            batchNo: _batchNo,
            distributor: result2,
            pharmacy: result3
        });
        return newVaccine;
    }

}
