// Import Express framework
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { supabase } from './src/config/supabaseClient.js';

// Import auth routes
import authRoutes from './src/routes/auth.js';

// Import product routes
import productRoutes from './src/routes/products.js';
import adminRoutes from './src/routes/admin.js';

// Load environment variables
dotenv.config();

// Create Express app
const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// ============ ROUTES ============

// Root route
app.get('/', (req, res) => {
  console.log(' Root route accessed');
  res.json({
    message: 'Aurix Backend is running',
    timestamp: new Date().toISOString(),
    available_endpoints: [
      'POST /api/auth/signup',
      'POST /api/auth/login',
      'POST /api/products',
      'GET /api/products',
      'GET /api/products/:id',
      'PUT /api/products/:id',
      'DELETE /api/products/:id',
      'GET /api/admin/jewellers/pending',      // NEW
      'GET /api/admin/jewellers',              // NEW
      'POST /api/admin/jewellers/:id/approve', // NEW
      'POST /api/admin/jewellers/:id/reject',  // NEW
      'GET /api/admin/jewellers/:id/status',   // NEW
      'GET /test-db'
    ]
  });
});

// Auth routes - connects /api/auth to authRoutes
app.use('/api/auth', authRoutes);

// Product routes - connects /api/products to productRoutes
app.use('/api/products', productRoutes);

// Admin routes
app.use('/api/admin', adminRoutes);

// Test database connection
app.get('/test-db', async (req, res) => {
  console.log(' Testing database connection...');

  try {
    const { data, error, count } = await supabase
      .from('users')
      .select('*', { count: 'exact' });

    if (error) {
      console.error(' Database error:', error);
      return res.status(500).json({
        success: false,
        error: error.message
      });
    }

    console.log(' Database connected! Users count:', count);

    res.json({
      success: true,
      message: 'Database connected successfully',
      users_count: count,
      users: data
    });

  } catch (err) {
    console.error(' Server error:', err);
    res.status(500).json({
      success: false,
      error: 'Server error: ' + err.message
    });
  }
});

// ============ START SERVER ============

const PORT = process.env.PORT || 5000;

app.listen(PORT, '0.0.0.0', () => {
  console.log('='.repeat(70));
  console.log('AURIX BACKEND STARTED');
  console.log('='.repeat(70));
  console.log(`Server: http://localhost:${PORT}`);
  console.log(`Network: http://0.0.0.0:${PORT}`);
  console.log('');
  console.log('Available Endpoints:');
  console.log('');
  console.log('   AUTH:');
  console.log(`   POST /api/auth/signup           - Register (customer/jeweller)`);
  console.log(`   POST /api/auth/login            - Login`);
  console.log('');
  console.log('   PRODUCTS:');
  console.log(`   POST /api/products              - Add product`);
  console.log(`   GET  /api/products              - Get all products`);
  console.log(`   GET  /api/products/:id          - Get single product`);
  console.log(`   PUT  /api/products/:id          - Update product`);
  console.log(`   DELETE /api/products/:id        - Delete product`);
  console.log('');
  console.log('   ADMIN (NEW!):');
  console.log(`   GET  /api/admin/jewellers/pending       - Get pending jewellers`);
  console.log(`   GET  /api/admin/jewellers               - Get all jewellers`);
  console.log(`   GET  /api/admin/jewellers/:id           - Get jeweller details`);
  console.log(`   POST /api/admin/jewellers/:id/approve   - Approve jeweller`);
  console.log(`   POST /api/admin/jewellers/:id/reject    - Reject jeweller`);
  console.log(`   GET  /api/admin/jewellers/:id/status    - Check status`);
  console.log('');
  console.log('   TESTING:');
  console.log(`   GET  /                          - Server info`);
  console.log(`   GET  /test-db                   - Test database`);
  console.log('='.repeat(70));
});