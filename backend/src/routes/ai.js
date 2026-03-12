import express from 'express';
import {
  aiChat,
  aiSuggestions,
  aiHealthCheck,
} from '../controllers/aiChatController.js';

const router = express.Router();

// AI chat completion (main conversational endpoint)
router.post('/chat', aiChat);

// AI jewelry suggestions based on preferences
router.post('/suggestions', aiSuggestions);

// AI service health check
router.get('/health', aiHealthCheck);

export default router;
