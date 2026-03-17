import { fetchGoldRates } from '../services/goldRateService.js';

export async function getGoldRate(req, res) {
  try {
    const rates = await fetchGoldRates();
    res.json({ success: true, ...rates });
  } catch (err) {
    console.error('Gold rate error:', err);
    res.status(502).json({
      success: false,
      message: err?.message ?? 'Failed to fetch gold rates',
    });
  }
}
