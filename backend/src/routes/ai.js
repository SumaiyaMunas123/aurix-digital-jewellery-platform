import express from 'express';
import { generateImage, healthCheck } from '../controllers/aiController.js';
import {
  aiChat,
  aiSuggestions,
} from '../controllers/aiChatController.js';

const router = express.Router();

// GET /api/ai/health - Check if AI service is configured
router.get('/health', healthCheck);

// POST /api/ai/generate - Generate jewellery image from text prompt
router.post('/generate', generateImage);

// AI chat completion (main conversational endpoint)
router.post('/chat', aiChat);

// AI jewelry suggestions based on preferences
router.post('/suggestions', aiSuggestions);

export default router;
