import 'dotenv/config';
import express from 'express';
import cors from 'cors';

// Import routes
import authRoutes from './src/routes/auth.js';
import productRoutes from './src/routes/products.js';
import adminRoutes from './src/routes/admin.js';
import chatRoutes from './src/routes/chat.js';
import aiRoutes from './src/routes/ai.js';
import documentRoutes from './src/routes/documents.js';

const app = express();

// Middleware
app.use(cors({
  origin: process.env.FRONTEND_URL ? process.env.FRONTEND_URL.split(',') : true,
  credentials: true,
}));
app.use(express.json());

// Request logging
app.use((req, res, next) => {
  console.log(`\n[${new Date().toLocaleTimeString()}] ${req.method} ${req.path}`);
  next();
});

// Auth routes

app.use('/api/auth', authRoutes);

// Product routes

app.use('/api/products', productRoutes);

// Admin routes

app.use('/api/admin', adminRoutes);

// =Document routes

app.use('/api/documents', documentRoutes);

// ============ CHAT ROUTES ============

app.use('/api/chat', chatRoutes);

// ============ AI ROUTES ============

app.use('/api/ai', aiRoutes);

// ============ GOLD RATE GATEWAY ============

app.get('/gold-rate', async (req, res) => {
  try {
    const baseUrl = process.env.GOLD_RATE_SERVICE_URL || 'http://localhost:5100';
    const upstream = `${baseUrl.replace(/\/$/, '')}/api/gold-rate`;
    const response = await fetch(upstream, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' }
    });

    const payload = await response.json();
    return res.status(response.status).json(payload);
  } catch (error) {
    return res.status(502).json({
      success: false,
      message: 'Unable to reach gold-rate service',
      error: error.message
    });
  }
});


// Basic root routes

// Root route
app.get('/', (req, res) => {
  res.json({
    message: 'Aurix Backend is running',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    endpoints: {
      auth: '/api/auth',
      products: '/api/products',
      admin: '/api/admin',
      chat: '/api/chat'
    }
  });
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Start the server

const PORT = process.env.PORT || 5000;

const server = app.listen(PORT, '0.0.0.0', () => {
  console.log('');
  console.log('========================================');
  console.log('||   AURIX BACKEND RUNNING ! ||');
  console.log('========================================');
  console.log(` Server: http://localhost:${PORT}`);
  console.log(` Database: Connected to Supabase`);
  console.log('========================================');
  console.log('');
});

// Handle uncaught exceptions 
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});