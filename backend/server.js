import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { supabase } from './src/config/supabaseClient.js';

// Import routes
import authRoutes from './src/routes/auth.js';
import productRoutes from './src/routes/products.js';
import adminRoutes from './src/routes/admin.js';
import chatRoutes from './src/routes/chat.js';
import aiRoutes from './src/routes/ai.js';

// Import AI routes
import aiRoutes from './src/routes/ai.js';

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
      'GET /api/ai/health',                      // AI
      'POST /api/ai/generate',                   // AI
      'GET /test-db'
    ]
  });
});

// Auth routes - connects /api/auth to authRoutes
// Auth routes
app.use('/api/auth', authRoutes);

// Product routes
app.use('/api/products', productRoutes);

// Admin routes
app.use('/api/admin', adminRoutes);

// AI routes
app.use('/api/ai', aiRoutes);

// Chat routes
app.use('/api/chat', chatRoutes);

// AI routes (Groq-powered)
app.use('/api/ai', aiRoutes);

// Root route
app.get('/', (req, res) => {
  res.json({
    message: 'Aurix Backend is running',
    timestamp: new Date().toISOString()
  });
});

// Test database connection
app.get('/test-db', async (req, res) => {
  try {
    const { data, error, count } = await supabase
      .from('users')
      .select('*', { count: 'exact' });

    if (error) throw error;

    res.json({
      success: true,
      message: 'Database connected',
      users_count: count
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      error: err.message
    });
  }
});

// ============ START SERVER ============

const PORT = process.env.PORT || 5000;

app.listen(PORT, '0.0.0.0', () => {
  // console.log('╔════════════════════════════════════════╗');
  console.log('|| AURIX BACKEND RUNNING ! ||');
  // console.log('╚════════════════════════════════════════╝');
  console.log(` Server: http://localhost:${PORT}`);
  console.log(` Database: Connected to Supabase`);
  /*console.log('');
  console.log('📋 Available Routes:');
  console.log('   - POST /api/auth/signup');
  console.log('   - POST /api/auth/login');
  console.log('   - POST /api/products');
  console.log('   - GET  /api/products');
  console.log('   - GET  /api/products/:id');
  console.log('   - PUT  /api/products/:id');
  console.log('   - GET  /api/admin/jewellers/pending');
  console.log('   - PUT  /api/admin/jewellers/:id/approve');
  console.log('   - PUT  /api/admin/jewellers/:id/reject');
  console.log('');
  console.log('   AI:');
  console.log(`   GET  /api/ai/health             - AI service status`);
  console.log(`   POST /api/ai/generate           - Generate jewellery image`);
  console.log('');
  console.log('   TESTING:');
  console.log(`   GET  /                          - Server info`);
  console.log(`   GET  /test-db                   - Test database`);
  console.log('='.repeat(70));
  console.log('Ready to accept requests! 🎉');
  console.log('════════════════════════════════════════');*/
});