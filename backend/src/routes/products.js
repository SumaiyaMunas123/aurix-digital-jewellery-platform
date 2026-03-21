import express from 'express';
import { requireAuth, requireRole } from '../middleware/auth.js';
import {
  addProduct,
  getAllProducts,
  getProductById,
  getJewellerProducts,
  updateProduct,
  updateStock,
  deleteProduct,
  toggleProductVisibility,
  getCategories,
} from '../controllers/productController.js';
import {
  addProductImage,
  getProductImages,
  setPrimaryImage,
  deleteProductImage,
} from '../controllers/productImageController.js';

const router = express.Router();

// ── Public ────────────────────────────────────────────────────
router.get('/', getAllProducts);
router.get('/categories', getCategories);
router.get('/:id', getProductById);
router.get('/:id/images', getProductImages);

// ── Jeweller ──────────────────────────────────────────────────
router.post('/', requireAuth, requireRole('jeweller'), addProduct);
router.get('/jeweller/:jeweller_id', requireAuth, requireRole('jeweller', 'admin'), getJewellerProducts);
router.put('/:id', requireAuth, requireRole('jeweller'), updateProduct);
router.patch('/:id/stock', requireAuth, requireRole('jeweller'), updateStock);
router.patch('/:id/toggle-visibility', requireAuth, requireRole('jeweller'), toggleProductVisibility);
router.delete('/:id', requireAuth, requireRole('jeweller'), deleteProduct);

// Images — jeweller uploads file client-side to Supabase Storage,
// then sends the resulting URL + storage_path to these endpoints
router.post('/:id/images', requireAuth, requireRole('jeweller'), addProductImage);
router.patch('/:id/images/:image_id/primary', requireAuth, requireRole('jeweller'), setPrimaryImage);
router.delete('/:id/images/:image_id', requireAuth, requireRole('jeweller', 'admin'), deleteProductImage);

export default router;