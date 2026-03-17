import express from 'express';
import {
  deleteDesign,
  generateWithStyle,
  getDesignById,
  getUserDesigns,
  toggleFavorite,
  uploadSketch,
} from '../controllers/designController.js';

const router = express.Router();

router.get('/', getUserDesigns);
router.get('/:id', getDesignById);
router.delete('/:id', deleteDesign);
router.patch('/:id/favorite', toggleFavorite);
router.post('/generate-styled', generateWithStyle);
router.post('/sketch-to-image', uploadSketch);

export default router;
