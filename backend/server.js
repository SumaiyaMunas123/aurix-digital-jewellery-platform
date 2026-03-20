import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { supabase } from './src/config/supabaseClient.js';
import { errorHandler, notFoundHandler } from './src/middleware/errorHandler.js';
import { sendError } from './src/utils/responseFormatter.js';

// Import routes
import authRoutes from './src/routes/auth.js';
import productRoutes from './src/routes/products.js';
import adminRoutes from './src/routes/admin.js';
import chatRoutes from './src/routes/chat.js';
import aiRoutes from './src/routes/ai.js';

dotenv.config();

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

// ============ AUTH ROUTES ============ 

app.use('/api/auth', authRoutes);

// ============ PRODUCT ROUTES ============

app.use('/api/products', productRoutes);

// ============ ADMIN ROUTES ============

app.use('/api/admin', adminRoutes);

// ============ CHAT ROUTES ============

app.use('/api/chat', chatRoutes);

// ============ AI ROUTES ============

app.use('/api/ai', aiRoutes);

// ============ GOLD RATE GATEWAY ============

app.get('/gold-rate', async (req, res) => {
  try {
    const baseUrl = process.env.GOLD_RATE_SERVICE_URL || 'http://localhost:5100';
    const upstream = `${baseUrl.replace(/\/$/, '')}/api/gold-rate`;
    
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 8000); // 8 second timeout

    const response = await fetch(upstream, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' },
      signal: controller.signal
    });

    clearTimeout(timeoutId);

    if (!response.ok) {
      let errorData;
      try {
        errorData = await response.json();
      } catch (e) {
        errorData = { message: 'Invalid response from gold-rate service' };
      }
      return sendError(res, errorData.message || 'Gold-rate service error', response.status);
    }

    const payload = await response.json();
    return res.status(200).json({
      success: true,
      message: 'Gold rates retrieved',
      data: payload,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    if (error.name === 'AbortError') {
      return sendError(res, 'Gold-rate service timeout', 504);
    }
    console.error('❌ Gold-rate gateway error:', error.message);
    return sendError(res, 'Unable to reach gold-rate service', 502);
  }
});


// ============ BASIC ROUTES ============

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

// ============ ERROR HANDLING ============

// 404 handler
app.use(notFoundHandler);

// Centralized error handler (must be last)
app.use(errorHandler);

// ============ START SERVER ============

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

// Handle uncaught exceptions and rejections
process.on('uncaughtException', (err) => {
  console.error('❌ Uncaught Exception:', err.message);
  process.exit(1);
});

process.on('unhandledRejection', (reason) => {
  console.error('❌ Unhandled Rejection:', reason);
  process.exit(1);
});