const express = require('express');
const http = require('http');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
require('dotenv').config();

const connectDB = require('./config/db');
const seedAllData = require('./services/seedData');
const errorHandler = require('./middleware/errorHandler');

// Route imports
const authRoutes = require('./routes/authRoutes');
const donorRoutes = require('./routes/donorRoutes');
const recipientRoutes = require('./routes/recipientRoutes');
const organRoutes = require('./routes/organRoutes');
const matchingRoutes = require('./routes/matchingRoutes');
const allocationRoutes = require('./routes/allocationRoutes');
const transferRoutes = require('./routes/transferRoutes');
const emergencyRoutes = require('./routes/emergencyRoutes');
const hospitalRoutes = require('./routes/hospitalRoutes');
const dashboardRoutes = require('./routes/dashboardRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const auditRoutes = require('./routes/auditRoutes');

const app = express();

// Middleware
app.use(cors({
  origin: '*',
  credentials: true,
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve uploaded medical documents statically
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/donors', donorRoutes);
app.use('/api/recipients', recipientRoutes);
app.use('/api/organs', organRoutes);
app.use('/api/matching', matchingRoutes);
app.use('/api/allocations', allocationRoutes);
app.use('/api/transfers', transferRoutes);
app.use('/api/emergency', emergencyRoutes);
app.use('/api/hospitals', hospitalRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/audit-logs', auditRoutes);

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'GraftGuard Secure Organ System Backend API is active and running',
    version: '1.0.0',
    timestamp: new Date(),
  });
});

// Serve Frontend Static Build
const frontendDist = path.join(__dirname, '..', 'frontend', 'dist');
if (fs.existsSync(frontendDist)) {
  app.use(express.static(frontendDist));
  app.get('*', (req, res, next) => {
    if (req.path.startsWith('/api') || req.path.startsWith('/uploads')) {
      return next();
    }
    res.sendFile(path.join(frontendDist, 'index.html'));
  });
}

// Error Handler Middleware
app.use(errorHandler);

// Listen on Port 5000 (primary for Vite proxy and APIs)
const PORT = process.env.PORT || 5000;
const server5000 = http.createServer(app);
server5000.listen(PORT, () => {
  console.log(`=======================================================`);
  console.log(`  GraftGuard Backend Server Running on Port ${PORT}    `);
  console.log(`  API Base: http://localhost:${PORT}/api               `);
  console.log(`=======================================================`);
});

// Also listen on Port 3000 as secondary
try {
  const server3000 = http.createServer(app);
  server3000.listen(3000, () => {
    console.log(`  Also accessible at: http://localhost:3000            `);
    console.log(`=======================================================`);
  });
} catch (e) {
  // port in use
}

// Connect Database Asynchronously
connectDB()
  .then(async () => {
    await seedAllData();
  })
  .catch((err) => {
    console.warn(`[Notice] Database connection waiting: ${err.message}`);
  });

module.exports = app;
