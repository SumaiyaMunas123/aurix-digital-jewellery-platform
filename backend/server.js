// Import Express framework
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { supabase } from './src/config/supabase.js';

// Import auth routes
import authRoutes from './src/routes/auth.js';

// Import product routes
import productRoutes from './src/routes/products.js';  

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
      'GET /test-db'
    ]
  });
});

// Auth routes - connects /api/auth to authRoutes
app.use('/api/auth', authRoutes);

// Product routes - connects /api/products to productRoutes
app.use('/api/products', productRoutes);

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
  console.log('='.repeat(60));
  console.log(' AURIX BACKEND STARTED');
  console.log('='.repeat(60));
  console.log(` Server: http://localhost:${PORT}`);
  console.log('');
  console.log(' Available Endpoints:');
  console.log(`   GET  /                    - Server info`);
  console.log(`   GET  /test-db             - Test database`);
  console.log(`   POST /api/auth/signup     - Register new user`);
  console.log(`   POST /api/auth/login      - Login user`);
  console.log(`   POST /api/products          - Add product`);          
  console.log(`   GET  /api/products          - Get all products`);      
  console.log(`   GET  /api/products/:id      - Get single product`);    
  console.log(`   PUT  /api/products/:id      - Update product`);       
  console.log(`   DELETE /api/products/:id    - Delete product`); 
  console.log('='.repeat(60));
});