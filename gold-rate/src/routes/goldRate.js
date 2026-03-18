import express from 'express';
import { getGoldRate, getGoldPrice, getSilverPrice, getPlatinumPrice } from '../controllers/goldRateController.js';

const router = express.Router();

// GET /api/gold-rate (all rates)
router.get('/', getGoldRate);

// GET /api/gold-rate/gold
router.get('/gold', getGoldPrice);

// GET /api/gold-rate/silver
router.get('/silver', getSilverPrice);

// GET /api/gold-rate/platinum
router.get('/platinum', getPlatinumPrice);

export default router;
