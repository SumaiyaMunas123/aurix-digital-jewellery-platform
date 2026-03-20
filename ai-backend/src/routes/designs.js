import express from 'express';
import {
  deleteDesign,
  generateWithStyle,
  getDesignById,
  getUserDesigns,
  toggleFavorite,
  uploadSketch,
} from '../controllers/designController.js';
import { validateUserAuth } from '../middleware/auth.js';
import { 
  timeoutHandler, 
  validatePrompt, 
  validateGenerationParams,
  rateLimitAI 
} from '../middleware/validation.js';

const router = express.Router();

// All design routes require user authentication
router.use(validateUserAuth);

// GET all designs for a user (supports pagination and filtering)
router.get('/', getUserDesigns);

// GET single design by ID
router.get('/:id', getDesignById);

// DELETE design by ID (with user scoping check in controller)
router.delete('/:id', deleteDesign);

// PATCH design favorite status (with user scoping check in controller)
router.patch('/:id/favorite', toggleFavorite);

// POST generate image with style parameters (with rate limiting and timeout)
router.post('/generate-styled', 
  timeoutHandler(120000),
  rateLimitAI,
  validatePrompt,
  validateGenerationParams,
  generateWithStyle
);

// POST upload sketch and generate from sketch (with rate limiting and timeout)
router.post('/sketch-to-image',
  timeoutHandler(120000),
  rateLimitAI,
  validatePrompt,
  uploadSketch
);

export default router;
