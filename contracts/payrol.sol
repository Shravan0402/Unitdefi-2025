// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Payroll is Ownable {
    struct Employee {
        address walletAddress;
        uint256 salary;
        address preferredToken;
    }

    mapping(address => Employee) public employees;
    address[] public employeeList;

    event EmployeeAdded(address indexed employeeAddress, uint256 salary, address indexed preferredToken);
    event PaymentMade(address indexed employeeAddress, uint256 amount, address indexed token);
    event FundsDeposited(address indexed from, uint256 amount, address indexed token);

    constructor() Ownable(msg.sender) {}

    function addEmployee(address _walletAddress, uint256 _salary, address _preferredToken) public onlyOwner {
        require(_walletAddress != address(0), "Invalid employee address");
        require(_salary > 0, "Salary must be greater than zero");

        if (employees[_walletAddress].walletAddress == address(0)) {
            employeeList.push(_walletAddress);
        }

        employees[_walletAddress] = Employee(_walletAddress, _salary, _preferredToken);
        emit EmployeeAdded(_walletAddress, _salary, _preferredToken);
    }

    function depositFunds(address _token, uint256 _amount) public payable {
        require(_amount > 0, "Amount must be greater than zero");
        IERC20 token = IERC20(_token);
        require(token.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");
        emit FundsDeposited(msg.sender, _amount, _token);
    }

    function payEmployee(address _employeeAddress) public onlyOwner {
        Employee memory employee = employees[_employeeAddress];
        require(employee.walletAddress != address(0), "Employee not found");

        IERC20 token = IERC20(employee.preferredToken);
        require(token.balanceOf(address(this)) >= employee.salary, "Insufficient funds to make payment");

        require(token.transfer(employee.walletAddress, employee.salary), "Payment failed");
        emit PaymentMade(_employeeAddress, employee.salary, employee.preferredToken);
    }

    function batchPayEmployees() public onlyOwner {
        for (uint i = 0; i < employeeList.length; i++) {
            payEmployee(employeeList[i]);
        }
    }

    // Placeholder for 1inch Fusion+ integration
    function swapAndPay(address _fromToken, uint256 _amount, address _toToken, address _employeeAddress) public onlyOwner {
        // This function would interact with the 1inch router to perform a swap
        // and then pay the employee in their preferred token.
        // For now, it's a placeholder.
    }
    
    function getEmployeeCount() public view returns (uint256) {
        return employeeList.length;
    }
}
