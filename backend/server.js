import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { supabase } from './src/config/supabaseClient.js';

// Import routes
import authRoutes from './src/routes/auth.js';
import productRoutes from './src/routes/products.js';
import adminRoutes from './src/routes/admin.js';
import chatRoutes from './src/routes/chat.js';

dotenv.config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());


// ============ AUTH ROUTES ============ 

app.use('/api/auth', authRoutes);

// ============ PRODUCT ROUTES ============

app.use('/api/products', productRoutes);

// ============ ADMIN ROUTES ============

app.use('/api/admin', adminRoutes);

// ============ CHAT ROUTES ============

app.use('/api/chat', chatRoutes);


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

// ============ START SERVER ============

const PORT = process.env.PORT || 5000;

app.listen(PORT, '0.0.0.0', () => {
  console.log('');
  console.log('========================================');
  console.log('||   AURIX BACKEND RUNNING ! ||');
  console.log('========================================');
  console.log(` Server: http://localhost:${PORT}`);
  console.log(` Database: Connected to Supabase`);
  console.log('========================================');
  console.log('');
});