import express from 'express';
import {
  signup,
  login,
  googleAuth,
  requestEmailVerification,
  verifyEmailCode,
  logout,
} from '../controllers/authController.js';

const router = express.Router();
router.post('/signup', signup);
router.post('/login', login);
router.post('/google', googleAuth);
router.post('/logout', logout);
router.post('/email/request-verification', requestEmailVerification);
router.post('/email/verify-code', verifyEmailCode);

export default router;