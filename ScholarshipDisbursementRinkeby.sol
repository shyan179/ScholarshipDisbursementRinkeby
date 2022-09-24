// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.0 <0.9.0;

//This is only use in Rinkeby testnet
import "./priceConvertRinkeby.sol"; 

// Build the Contract for student side 
contract StuDetails
{
	// Create a structure for
	// student details
	struct Student
	{
		uint256 ID;
		string FirstName;
		string LastName;
		address payable Address;
	}

	//Define variables
	address stuAdd;
	mapping(uint256 => Student) internal stuRecords;
	Student[] internal student;


	// Create a function to add
	// the new records
	function addStuRecords(uint256 _ID,
						string memory _FirstName,
						string memory _LastName) public
	{	//error message if student try to enter using the same ID again
		require(stuRecords[_ID].ID != _ID,"____Student ID already registered and cannot be altered____");
		// Get the student address
		stuAdd = msg.sender;

		//Add to array
		student.push(Student({ID: _ID, FirstName: _FirstName, 
					LastName: _LastName, Address: payable(stuAdd)}));

		// Fetch the student details
		// with the student ID
		stuRecords[_ID] = Student(_ID, _FirstName,
									_LastName, payable(stuAdd));
	}
	
	//function to view the student array
	function getStuDetails(uint256 _ID) public view returns(uint256, string memory, string memory, address payable) {
    	uint256 ID = stuRecords[_ID].ID; 
		string memory FirstName = stuRecords[_ID].FirstName;
		string memory LastName = stuRecords[_ID].LastName; 
		address payable Address = stuRecords[_ID].Address;
		return (ID, FirstName, LastName, Address);
  	}

}

// Build the Contract for scholarship provider
contract ScholarDetails {

	//Get the addresses of another 3 contracts
	address PriceContractAdd; //this only relevant for running on rinkeby testnet to get value in GBP
	address StuContractAdd;
	address payable StaffContractAdd;

	constructor (address _StuContractAdd, address _PriceContractAdd) payable  {
		StuContractAdd = _StuContractAdd;
		PriceContractAdd = _PriceContractAdd;
	}

	function storeContractAdd(address payable _StaffContractAdd) public {
        StaffContractAdd = _StaffContractAdd;
    }

	//This is mandatory for receiving ETH
    event ReceivedEth(uint256 amount);

    receive() external payable  { 
        emit ReceivedEth(msg.value);
    }

    fallback() external payable {
        emit ReceivedEth(msg.value);
    }

	//view the amount converted
	function viewGBPWEI(uint256 _number) public view returns (uint256) {
		PriceConversion p = PriceConversion(PriceContractAdd);
        uint256 price = p.getGBPWEI(_number);
        return price;
    }

	// defining scholarship details struct
    struct Scholarship {
		uint256 ID;
        string ScholarshipName;
        uint256 Amount;
        address Provider;
        uint256 Attendance;
		uint256 AvgMark;
		string Status;
    }
	//Define variables
	address payable provAdd;
	string Status;
	mapping(uint256 => Scholarship) internal schlRecords;
	Scholarship[] internal scholarship;
	
	// Create a function to add
	// the new scholarship records
	function addSchlRecords(uint256 _ID,
						string memory _ScholarshipName,
						uint256 _Amount,
						uint256 _Attendance,
						uint256 _AvgMark) payable public 

	{	//Convert the amount from GBP to wei
		PriceConversion p = PriceConversion(PriceContractAdd);
		uint256 cvrAmt = p.getGBPWEI(_Amount);
		
		//Show error if there is not enough balance to offer the scholarship
		require(cvrAmt <= address(this).balance,"____This wallet does not have enough balance to offer the scholarship____");
		
		//Get the student ID stored on student contract
		uint256 stuID;
		StuDetails stu = StuDetails(StuContractAdd);
		(stuID, , , ) = stu.getStuDetails(_ID);
		
		//Show error if the student is not found
		require(_ID == stuID, "____The student ID entered is not found____");
		
		// Get the provider address
		provAdd = payable(msg.sender);
		//Set the default scholarship status as true
		Status = "active";

		//Add to array
		scholarship.push(Scholarship({ID: _ID, ScholarshipName: _ScholarshipName, 
									Amount: cvrAmt, Provider: provAdd, 
									Attendance: _Attendance, 
									AvgMark: _AvgMark, Status: Status}));

		// Fetch the sscholarship details
		// using the student ID
		schlRecords[_ID] = Scholarship(_ID, _ScholarshipName,
									cvrAmt, provAdd,
									_Attendance, _AvgMark,
									Status);

		//send the scholarship amount to staff contract for payment disbursement
        StaffContractAdd.transfer(cvrAmt);
	}

	//function to cancel scholarship
	function cancelScholarship (uint256 _ID) public {
		Scholarship storage _scholarship = schlRecords[_ID];
		//Show error if the student is not found
		require(_ID == _scholarship.ID, "____The student ID entered is either not found or no scholarship____");
		//only same address can cancel the scholarship
		require(_scholarship.Provider == msg.sender, "____Only scholarship owner can cancel the scholarship____"); 
		//only can cancel active scholarship
		require(keccak256(abi.encodePacked(_scholarship.Status)) == keccak256(abi.encodePacked(Status)), "____The scholarship is already cancelled, no further cancelation needed____");
		_scholarship.Status = "pending_refund";

	}

	//function to view the scholarship array
	function getSchlDetails(uint256 _ID) public view returns(uint256, uint256, address payable, uint256, uint256, string memory) {
		uint256 ID = schlRecords[_ID].ID;
        uint256 Amount = schlRecords[_ID].Amount;
		address payable Provider = payable(schlRecords[_ID].Provider);
        uint256 Attendance = schlRecords[_ID].Attendance;
		uint256 AvgMark = schlRecords[_ID].AvgMark;
		string memory Stat = schlRecords[_ID].Status;
		return (ID, Amount, Provider, Attendance, AvgMark, Stat);
  	}

	//function to get the scholarship status
	function getStatus(uint256 _ID) public view returns(string memory) {
		string memory Stat = schlRecords[_ID].Status;
		return Stat;
	}
	
	//function to update the scholarship status to cancel
	function updStatCancel (uint256 _ID) public {
		Scholarship storage _scholarship = schlRecords[_ID];
		_scholarship.Status = "cancel";
	}

	//function to update the scholarship status to paid
	function updStatPaid (uint256 _ID) public {
		Scholarship storage _scholarship = schlRecords[_ID];
		_scholarship.Status = "paid";
	}

	//function to update the scholarship status to failed
	function updStatFailed (uint256 _ID) public {
		Scholarship storage _scholarship = schlRecords[_ID];
		_scholarship.Status = "failed";
	}

	//function to update the scholarship status to active
	function updStatActive (uint256 _ID) public {
		Scholarship storage _scholarship = schlRecords[_ID];
		_scholarship.Status = "active";
	}
}

// Build the Contract for staff
contract Staff{

	//get the other 2 contract addresses
	address StuContractAdd;
	address payable SchlContractAdd;

	constructor (address _StuContractAdd, address _SchlContractAdd) payable {
		StuContractAdd = _StuContractAdd;
		SchlContractAdd = payable(_SchlContractAdd);
	}

	//This is mandatory for receiving ETH
    event ReceivedEth(uint256 amount);

    receive() external payable  { 
        emit ReceivedEth(msg.value);
    }

    fallback() external payable {
        emit ReceivedEth(msg.value);
    }

	// defining result details struct
    struct Result {
		uint256 ID;
        uint256 Attendance;
		uint256 AvgMark;
    }

	//define variables
	uint256 id;
	address payable receiver;
	address payable provider;
	uint256 payAmt;
	string status;
	mapping(uint256 => Result) internal rsltRecords;
	Result[] internal result;

	// Create a function to staff to add
	// the student result
	function resultNpay(uint256 _ID,
						uint256 _Attendance,
						uint256 _AvgMark) payable public
	{
		//Add to array
		result.push(Result({ID: _ID, Attendance: _Attendance, 
									AvgMark: _AvgMark}));
		// Fetch the result details
		// using the student ID
		rsltRecords[_ID] = Result(_ID, _Attendance, 
									_AvgMark);

		//variables to capture info from Scholarship contract
		uint256 reqAtt;
		uint256 reqMark;

		//Get required info from Student contract
		StuDetails stu = StuDetails(StuContractAdd);
		(, , , receiver) = stu.getStuDetails(_ID);

		//Get required info from Scholarship contract
		ScholarDetails sc = ScholarDetails(SchlContractAdd);
		(id, payAmt, , reqAtt, reqMark, status) = sc.getSchlDetails(_ID);

		//error message if no student ID found either in student or scholarhsip contract
		require(_ID == id, "____The student ID entered is either not found or no scholarship____");
		//scholarship need to be active for the payment disbursement
		require(keccak256(abi.encodePacked(status)) == keccak256(abi.encodePacked('active')), "____The scholarship is not active____");

		//check is the attendance and mark meet the requirements from scholarhsip provider
		//if failed
		if (reqAtt > _Attendance || reqMark > _AvgMark) {
			//Update the status to failed
			sc.updStatFailed(_ID);
		} else {
			//if pass
			require(payAmt <= address(this).balance,"____This wallet does not have enough balance to pay to student____");
        	receiver.transfer(payAmt);

			//Update the status to paid
			sc.updStatPaid(_ID);
		}
	}

	//function to return the ETH back to provider if provider cancel the scholarship
	function processRefund(uint256 _ID) payable public {
	
		//Get required info from Scholarship contract
		ScholarDetails sc = ScholarDetails(SchlContractAdd);
		(id, payAmt, provider, , ,status) = sc.getSchlDetails(_ID);

		//Make sure the ID has scholarship record
		require(_ID == id, "____The student ID entered is either not found or no scholarship____");

		//Make sure the scholarship is pending refund
		require(keccak256(abi.encodePacked(status)) == keccak256(abi.encodePacked('pending_refund')), "____No refund pending____");
        
		//Make sure there is enough money for refund
		require(payAmt <= address(this).balance,"____This wallet does not have enough balance to perform refund____");

		//perform refund back to provider address
        provider.transfer(payAmt);

		//Update the status to cancel
		sc.updStatCancel(_ID);
    } 

	//function to activate back failed scholarship
	function processActivation(uint256 _ID) public {
	
		//Get required info from Scholarship contract
		ScholarDetails sc = ScholarDetails(SchlContractAdd);
		(id, payAmt, , , ,status) = sc.getSchlDetails(_ID);

		//Make sure the ID has scholarship record
		require(_ID == id, "____The student ID entered is either not found or no scholarship____");

		//Make sure the scholarship is failed
		require(keccak256(abi.encodePacked(status)) == keccak256(abi.encodePacked('failed')), "____The scholarship is not in failed status, no activation required____");

		//Update the status to active
		sc.updStatActive(_ID);
    } 

	//function to view the scholarship status in order to return correct messaging on frontend
	function viewStatus(uint256 _ID) public view returns(string memory) {
		//Get status info from Scholarship contract
		ScholarDetails sc = ScholarDetails(SchlContractAdd);
		string memory Stat = sc.getStatus(_ID);
		return Stat;
	}

}