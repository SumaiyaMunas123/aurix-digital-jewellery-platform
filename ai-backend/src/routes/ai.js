import express from 'express';
import multer from 'multer';
import path from 'path';
import { fileURLToPath } from 'url';
import { aiChat, aiSuggestions } from '../controllers/aiChatController.js';
import { generateImage, healthCheck } from '../controllers/aiController.js';
import { validateUserAuth, requireAuth } from '../middleware/auth.js';
import { rateLimitAI, validatePrompt, validateGenerationParams, timeoutHandler } from '../middleware/validation.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Configure multer for sketch uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, '../../temp'));
  },
  filename: (req, file, cb) => {
    const uniqueName = `sketch-${Date.now()}-${Math.random().toString(36).substr(2, 9)}${path.extname(file.originalname)}`;
    cb(null, uniqueName);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 50 * 1024 * 1024 }, // 50MB limit
  fileFilter: (req, file, cb) => {
    const allowedMimes = ['image/jpeg', 'image/png', 'image/webp'];
    if (allowedMimes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error(`File type ${file.mimetype} not allowed. Only JPEG, PNG, WebP allowed.`));
    }
  }
});

const router = express.Router();

router.get('/health', healthCheck);

// Apply auth to all routes
router.use(validateUserAuth);

// POST /api/ai/generate
// Body: { mode, prompt, category, weight, material, karat, style, occasion, budget, user_id, user_type }
// For sketch mode, include file upload
router.post(
  '/generate',
  timeoutHandler(120000), // 2 minute timeout
  rateLimitAI,
  validatePrompt,
  validateGenerationParams,
  upload.single('sketch'),
  generateImage
);

router.post('/chat', aiChat);
router.post('/suggestions', aiSuggestions);

export default router;
