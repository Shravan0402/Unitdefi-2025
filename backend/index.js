const express = require('express');
const cors = require('cors');
const payrollRoutes = require('./routes/payroll');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5001;

app.use(cors());
app.use(express.json());

app.use('/api/payroll', payrollRoutes);

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
