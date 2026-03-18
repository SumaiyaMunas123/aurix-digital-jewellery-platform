import express from 'express';
import { aiChat, aiSuggestions } from '../controllers/aiChatController.js';
import { generateImage, healthCheck } from '../controllers/aiController.js';

const router = express.Router();

router.get('/health', healthCheck);
router.post('/generate', generateImage);
router.post('/chat', aiChat);
router.post('/suggestions', aiSuggestions);

export default router;
