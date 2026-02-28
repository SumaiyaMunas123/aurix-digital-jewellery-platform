import express from 'express';
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
router.post('/', addProduct);
router.get('/jeweller/:jeweller_id', getJewellerProducts);
router.put('/:id', updateProduct);
router.patch('/:id/toggle-visibility', toggleProductVisibility);
router.delete('/:id', deleteProduct);

export default router;