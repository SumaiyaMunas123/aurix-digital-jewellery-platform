import express from 'express';
import {
  signup,
  login,
  googleAuth,
  requestEmailVerification,
  verifyEmailCode,
} from '../controllers/authController.js';

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

// Google auth route
router.post('/google', (req, res, next) => {
  console.log('🔥 GOOGLE AUTH ROUTE HIT!');
  googleAuth(req, res, next);
});

router.post('/email/request-verification', (req, res, next) => {
  requestEmailVerification(req, res, next);
});

router.post('/email/verify-code', (req, res, next) => {
  verifyEmailCode(req, res, next);
});

console.log('Routes registered: POST /signup, POST /login, POST /google, POST /email/request-verification, POST /email/verify-code');

// Export router
export default router;