const express = require('express');
const router = express.Router();
const { ethers } = require('ethers');
const oneInchService = require('../services/oneInchService');
const stellarService = require('../services/stellarService');

const PAYROLL_CONTRACT_ADDRESS = '0x51beccbb03ce01bf3ce9c9bafd2a0226c2c7a1cc';
const PAYROLL_CONTRACT_ABI = require('payrol.json').abi; 
const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);
const signer = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
const payrollContract = new ethers.Contract(PAYROLL_CONTRACT_ADDRESS, PAYROLL_CONTRACT_ABI, signer);

router.post('/add-employee', async (req, res) => {
  const { walletAddress, salary, preferredToken } = req.body;
  try {
    const tx = await payrollContract.addEmployee(walletAddress, salary, preferredToken);
    await tx.wait();
    res.status(201).send({ message: 'Employee added successfully', txHash: tx.hash });
  } catch (error) {
    res.status(500).send({ message: 'Error adding employee', error: error.message });
  }
});

router.post('/pay-employee', async (req, res) => {
    const { employeeAddress } = req.body;
    try {
        // Here you would call the 1inch service to swap funds if needed
        // For now, we directly pay with the preferred token
        const tx = await payrollContract.payEmployee(employeeAddress);
        await tx.wait();
        res.status(200).send({ message: 'Payment successful', txHash: tx.hash });
    } catch (error) {
        res.status(500).send({ message: 'Error making payment', error: error.message });
    }
});

// Placeholder for Stellar off-ramp
router.post('/withdraw-to-fiat', async (req, res) => {
    const { userId, amount, asset } = req.body;
    try {
        const result = await stellarService.initiateFiatOffRamp(userId, amount, asset);
        res.status(200).send(result);
    } catch (error) {
        res.status(500).send({ message: 'Error initiating fiat withdrawal', error: error.message });
    }
});


module.exports = router;
