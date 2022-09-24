# ScholarshipDisbursementRinkeby
### Overview
This is a proof-of-concept smart contracts built using solidity to show the automation on study loan/scholarship disbursement using blockchain. The smart contract is separated into 3 parts, student, loan/scholarship provider and university staff. A decentralised web application (dApp) has been created using ethers.js to connect with the smart contracts and metamask. The dApp allows higher education staff, loan/scholarship institutions and students to interact with the private Ethereum network and transfer the money disbursement automatically once the disbursement requirements are met.

### Wallet used
I am using web wallet - Metamask for this project. For this particular project version, I'm using Rinkeby Testnet (for your information, due to ETH Merge, the Rinkeby Testnet will be deprecated on Wednesday, October 5th, 2022, I built this version just solely to show the GBP to ETH conversion which Goerli is yet to have the pricefeed chainlink on USD/GBP) for the deployment and testing. There are 2 more versions using different testnets in other repository folders (Ganache and Goerli).

For more information
1. Metamask refer to this link: https://metamask.io/

### Solidity contracts
There are 4 smart contracts on this project and all of them are deployed to Rinkeby Testnet via Remix IDE, you can use the "priceConvertRinkeby.sol" and "ScholarshipDisbursementRinkeby.sol" and the addresses below on remix IDE to look at the functions.

1. PriceConvert Smart Contract Addrress: 
```
0xaD7965F07B44b4F2f84c0d8194dFdee69caE86Bd
```
2. Student Smart Contract Addrress: 
```
0xF8A1f69E254e8052526316435D54FdCF0D772a8E
```
3. Scholarship Provider Smart Contract Addrress: 
```
0x4f53f3f54fD19bfe1bcaE8B85B07F773054376c7
```
4. University Staff Smart Contract Addrress: 
```
0xaa31d34920fCBA7933Ce03cbDe59b46ff6f3b56C
```

### Run the front end in local node

##### Visual Studio Code
I use Visual Studio Code to create and edit my project. You need also need Visual Studio Code to run the local web server. You can find the latest version here: https://code.visualstudio.com/

Then download all the files in this repository and put them into a single folder in your local drive. Remember to unzip any zip file. 

Open the folder using visual studio code.

##### Node.js and NPM (Node Package Manager)
You need to have Node.js and NPM, which come together.

NB: Check if Node and NPM are already installed by inputting the following commands in the terminal:

```
node --version
npm --version
```
If they are installed, you will see something like this

![image](https://user-images.githubusercontent.com/99839809/192117838-4fd9495c-d778-41c4-b212-f9cbe36b7efd.png)


Else go to https://nodejs.org/en/ if you need to install it.

##### Running the local server
To execute the local web server. Type the below in the terminal:
```
node server.js
```

![image](https://user-images.githubusercontent.com/99839809/192117550-9435c0c5-3e12-47cc-8013-c022a3ddd3f4.png)

In your browser, go to the link below to access the frontend

http://localhost:3300

If the local web server is set up correctly, you will see the landing page below

![image](https://user-images.githubusercontent.com/99839809/192118933-6f05ca5d-c40b-4778-9f50-a8ca043a818b.png)

Each of the button in the landing page give you accesss as if to 3 different parties (Student, Scholarship Provider and University Staff)

### Student Page
Student Page allows the student to enter their student code (numeric only) and their details. The smart contract will store the wallet ID to the student record when execute the transaction, this will be used later on the scholarship payment to pay student directly to their wallet.

Error message will show if try to store a student code that already exists in the blockchain

![image](https://user-images.githubusercontent.com/99839809/192118029-a31aff37-84be-4f59-847b-4a14bfc02beb.png)


### Scholarship Provider Page
Scholarship Provider Page allows the scholarship provider to add scholarship to the student. If the provider tries to add scholarship to the student code that is not exists in the blockchain, it will create an error message.

When the provider add the scholarship, the wallet address of the provider will be stored to the scholarship record and the price convert function will convert the GBP amount entered to Wei and then metamask will be executed to transfer the Wei amount (you could refer the Goerli version for USD amount unit or Ganache version with no price conversion involved in other repository folders) to the Staff smart contract for disbursement later.

![image](https://user-images.githubusercontent.com/99839809/192119028-a81722be-f7e5-4969-a413-201eb2566784.png)

The provider can also cancel the scholarship if they decide not to sponsor by using the cancel scholarship function. The amount will not be return immediately to the provider, instead the university staff will need to process the refund.

![image](https://user-images.githubusercontent.com/99839809/192118313-1272159f-b9c2-41a0-b0d0-7866e37e0e93.png)


### University Staff Page
University Staff Page allows the staff to enter the attendance percentage and average result of the student, if the attendance and result meet the required percentage entered by the provider when add the scholarship, the student will be disbursed the scholarship amount directly to their wallet address. Else the scholarship will mark as failed.

![image](https://user-images.githubusercontent.com/99839809/192118396-b3c1bcbb-9cae-41d4-aebd-c6f4ed0af137.png)

For those scholarships that have been cancelled by provider, staff can perform the refund to refund back the money of the provider from the smart contract. The money will be send to the provider wallet.

![image](https://user-images.githubusercontent.com/99839809/192118399-cfc65e3a-91b1-4574-9aee-7d199a814c1a.png)

For those failed scholarship due to not meeting the attendance and result criteria, staff can reactivate them to reinsert new result or attendance for the payment to be disbursed.

![image](https://user-images.githubusercontent.com/99839809/192118402-54ae14b5-45f0-4e9c-bd51-39a6bbf9a136.png)
