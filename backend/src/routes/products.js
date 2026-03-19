import express from 'express';
import { requireAuth, requireRole } from '../middleware/auth.js';
import { 
  addProduct, 
  getAllProducts, 
  getProductById,
  getJewellerProducts,
  updateProduct, 
  deleteProduct,
  toggleProductVisibility,
  getCategories
} from '../controllers/productController.js';

const router = express.Router();

// Public routes
router.get('/', getAllProducts);
router.get('/categories', getCategories);
router.get('/:id', getProductById);

// Jeweller routes
router.post('/', requireAuth, requireRole('jeweller'), addProduct);
router.get('/jeweller/:jeweller_id', requireAuth, requireRole('jeweller', 'admin'), getJewellerProducts);
router.put('/:id', requireAuth, requireRole('jeweller'), updateProduct);
router.patch('/:id/toggle-visibility', requireAuth, requireRole('jeweller'), toggleProductVisibility);
router.delete('/:id', requireAuth, requireRole('jeweller'), deleteProduct);

export default router;