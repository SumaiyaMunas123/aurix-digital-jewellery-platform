import express from 'express';
import { 
  getPendingJewellers,
  getAllJewellers,
  approveJeweller, 
  rejectJeweller,
  getVerificationStatus,
  getJewellerDetails
} from '../controllers/adminController.js';

const router = express.Router();

console.log('✅ Admin routes file loaded!');

// ==================== ADMIN ROUTES ====================

// Get all pending jewellers
// GET /api/admin/jewellers/pending
router.get('/jewellers/pending', getPendingJewellers);

// Get all jewellers (all statuses)
// GET /api/admin/jewellers
router.get('/jewellers', getAllJewellers);

// Get single jeweller details
// GET /api/admin/jewellers/:jeweller_id
router.get('/jewellers/:jeweller_id', getJewellerDetails);

// Approve jeweller
// POST /api/admin/jewellers/:jeweller_id/approve
// Body: { admin_id: "optional_admin_id" }
router.post('/jewellers/:jeweller_id/approve', approveJeweller);

// Reject jeweller
// POST /api/admin/jewellers/:jeweller_id/reject
// Body: { admin_id: "optional_admin_id", reason: "reason for rejection" }
router.post('/jewellers/:jeweller_id/reject', rejectJeweller);

// Check verification status
// GET /api/admin/jewellers/:jeweller_id/status
router.get('/jewellers/:jeweller_id/status', getVerificationStatus);

console.log('Admin routes registered');

export default router;