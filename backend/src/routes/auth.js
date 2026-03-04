import express from 'express';
import { signup, login } from '../controllers/authController.js';

// Create router
const router = express.Router();

console.log('Auth routes file loaded!');

// TEST ROUTE - just to check if /api/auth works
router.get('/test', (req, res) => {
  console.log('🔥 TEST ROUTE HIT!');
  res.json({ message: 'Auth routes are working!' });
});

// ==================== AUTH ROUTES ====================

// Signup route
router.post('/signup', (req, res, next) => {
  console.log('🔥 SIGNUP ROUTE HIT!');
  signup(req, res, next);
});

// Login route  
router.post('/login', (req, res, next) => {
  console.log('🔥 LOGIN ROUTE HIT!');
  login(req, res, next);
});

console.log('Routes registered: POST /signup, POST /login');

// Export router
export default router;