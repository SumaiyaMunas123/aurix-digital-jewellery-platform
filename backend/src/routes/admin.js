import express from 'express';
import { adminLogin } from '../controllers/adminLogin.js';
import { requireAdmin, requireAuth } from '../middleware/auth.js';
import {
  getPendingJewellers,
  getAllJewellers,
  getJewellerStatus,
  approveJeweller,
  rejectJeweller,
  getPlatformStats
} from '../controllers/adminController.js';

const router = express.Router();

// ============ AUTH ============
router.post('/login', adminLogin);

// Verify existing token and return the user — used on page reload
router.get('/verify', requireAuth, requireAdmin, (req, res) => {
  return res.status(200).json({
    success: true,
    user: req.user,
  });
});

// ============ JEWELLERS ============
router.get('/jewellers', requireAuth, requireAdmin, getAllJewellers);
router.get('/jewellers/pending', requireAuth, requireAdmin, getPendingJewellers);
router.get('/jewellers/:jeweller_id/status', requireAuth, requireAdmin, getJewellerStatus);
router.put('/jewellers/:jeweller_id/approve', requireAuth, requireAdmin, approveJeweller);
router.put('/jewellers/:jeweller_id/reject', requireAuth, requireAdmin, rejectJeweller);

// ============ STATS ============
router.get('/stats', requireAuth, requireAdmin, getPlatformStats);

export default router;