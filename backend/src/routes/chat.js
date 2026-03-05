import express from 'express';
import { 
  startChat,
  sendMessage,
  getChatThreads,
  getMessages,
  markAsRead,
  sendQuotation,
  shareAIDesign  // NEW
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

// Share AI design (NEW)
router.post('/share-design', shareAIDesign);

export default router;
```

---

## 🧪 **TEST UPDATED VERSION**

### **Test 1: Send Message**
```
POST http://localhost:5000/api/chat/send

Body:
{
  "thread_id": "THREAD_UUID",
  "sender_id": "USER_UUID",
  "message": "Hello, I'm interested!",
  "message_type": "text"
}
```

---

### **Test 2: Share AI Design**
```
POST http://localhost:5000/api/chat/share-design

Body:
{
  "thread_id": "THREAD_UUID",
  "sender_id": "CUSTOMER_UUID",
  "ai_design_id": "AI_DESIGN_UUID"
}
```

---

### **Test 3: Send Quotation**
```
POST http://localhost:5000/api/chat/quotation

Body:
{
  "thread_id": "THREAD_UUID",
  "jeweller_id": "JEWELLER_UUID",
  "quotation_id": "QUOTATION_UUID"
}