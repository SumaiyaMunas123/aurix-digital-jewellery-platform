import express from 'express';
import { generateImage, healthCheck } from '../controllers/aiController.js';

const router = express.Router();

// GET /api/ai/health - Check if AI service is configured
router.get('/health', healthCheck);

// POST /api/ai/generate - Generate jewellery image from text prompt
router.post('/generate', generateImage);

export default router;
