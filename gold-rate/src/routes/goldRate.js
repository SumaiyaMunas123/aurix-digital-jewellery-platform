import express from 'express';
import { getGoldRate } from '../controllers/goldRateController.js';

const router = express.Router();

// GET /api/gold-rate
router.get('/', getGoldRate);

export default router;
