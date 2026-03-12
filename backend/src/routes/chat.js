import express from 'express';
import {
  startChat,
  sendMessage,
  getChatThreads,
  getMessages,
  markAsRead,
  sendQuotation,
  shareAIDesign
} from '../controllers/chatController.js';

const router = express.Router();

// Start or get existing chat thread
router.post('/start', startChat);

// Send message
router.post('/send', sendMessage);

// Get user's chat threads
router.get('/threads/:user_id', getChatThreads);

// Get messages in a thread
router.get('/:thread_id/messages', getMessages);

// Mark messages as read
router.post('/read', markAsRead);

// Send quotation (special message type)
router.post('/quotation', sendQuotation);

// Share AI design
router.post('/share-design', shareAIDesign);

export default router;