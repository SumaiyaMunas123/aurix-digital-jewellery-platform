import express from 'express';
import { 
  getPendingJewellers,
  getAllJewellers,
  getJewellerStatus,
  approveJeweller,
  rejectJeweller,
  getPlatformStats
} from '../controllers/adminController.js';

const router = express.Router();

router.get('/jewellers', getAllJewellers);
router.get('/jewellers/pending', getPendingJewellers);
router.get('/jewellers/:jeweller_id/status', getJewellerStatus);
router.put('/jewellers/:jeweller_id/approve', approveJeweller);
router.put('/jewellers/:jeweller_id/reject', rejectJeweller);
router.get('/stats', getPlatformStats);

export default router;