import express from 'express';
import { adminLogin } from '../controllers/adminLogin.js';
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

// ============ JEWELLERS ============
router.get('/jewellers', getAllJewellers);
router.get('/jewellers/pending', getPendingJewellers);
router.get('/jewellers/:jeweller_id/status', getJewellerStatus);
router.put('/jewellers/:jeweller_id/approve', approveJeweller);
router.put('/jewellers/:jeweller_id/reject', rejectJeweller);

// ============ STATS ============
router.get('/stats', getPlatformStats);

export default router;
