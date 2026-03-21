import express from 'express';
import { adminLogin } from '../controllers/adminLogin.js';
import { requireAuth, requireAdmin } from '../middleware/auth.js';
import {
  getPendingJewellers,
  getAllJewellers,
  getJewellerStatus,
  approveJeweller,
  rejectJeweller,
  getPlatformStats,
} from '../controllers/adminController.js';
import {
  adminGetAllProducts,
  adminGetProductById,
  adminApproveProduct,
  adminRejectProduct,
  adminDeleteProduct,
  adminToggleProductVisibility,
  adminGetProductStats,
  adminGetProductsByJeweller,
} from '../controllers/adminProductController.js';

const router = express.Router();

// ============ AUTH ============
router.post('/login', adminLogin);

router.get('/verify', requireAuth, requireAdmin, (req, res) => {
  return res.status(200).json({ success: true, user: req.user });
});

// ============ JEWELLERS ============
router.get('/jewellers', requireAuth, requireAdmin, getAllJewellers);
router.get('/jewellers/pending', requireAuth, requireAdmin, getPendingJewellers);
router.get('/jewellers/:jeweller_id/status', requireAuth, requireAdmin, getJewellerStatus);
router.put('/jewellers/:jeweller_id/approve', requireAuth, requireAdmin, approveJeweller);
router.put('/jewellers/:jeweller_id/reject', requireAuth, requireAdmin, rejectJeweller);

// ============ STATS ============
router.get('/stats', requireAuth, requireAdmin, getPlatformStats);

// ============ PRODUCT MANAGEMENT ============

// Dashboard stats: total, approved, pending, flagged, rejected, top viewed, top sold
router.get('/products/stats', requireAuth, requireAdmin, adminGetProductStats);

// List all products — filters: ?search=&category=&admin_status=&is_active=&page=&limit=
router.get('/products', requireAuth, requireAdmin, adminGetAllProducts);

// Single product detail
router.get('/products/:id', requireAuth, requireAdmin, adminGetProductById);

// Approve a product (pending → approved  OR  flagged → approved)
// Returns 400 if stock_quantity is 0 — jeweller must restock first
router.patch('/products/:id/approve', requireAuth, requireAdmin, adminApproveProduct);

// Reject a product (pending → rejected  OR  flagged → rejected)
// Body (optional): { reason: "..." }
router.patch('/products/:id/reject', requireAuth, requireAdmin, adminRejectProduct);

// Hard delete
router.delete('/products/:id', requireAuth, requireAdmin, adminDeleteProduct);

// Hide / show without changing admin_status (body: { is_active: true/false } or omit to toggle)
router.patch('/products/:id/visibility', requireAuth, requireAdmin, adminToggleProductVisibility);

// All products by a specific jeweller
router.get('/jewellers/:jeweller_id/products', requireAuth, requireAdmin, adminGetProductsByJeweller);

export default router;