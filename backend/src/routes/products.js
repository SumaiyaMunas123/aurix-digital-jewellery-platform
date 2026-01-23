import express from 'express';
import { 
  addProduct, 
  getAllProducts, 
  getProductById, 
  updateProduct, 
  deleteProduct 
} from '../controllers/productController.js';

// Create router
const router = express.Router();

// ==================== PRODUCT ROUTES ====================

// Add new product
// POST /api/products
router.post('/', addProduct);

// Get all products
// GET /api/products
router.get('/', getAllProducts);

// Get single product by ID
// GET /api/products/:id
router.get('/:id', getProductById);

// Update product
// PUT /api/products/:id
router.put('/:id', updateProduct);

// Delete product
// DELETE /api/products/:id
router.delete('/:id', deleteProduct);

// Export router
export default router;