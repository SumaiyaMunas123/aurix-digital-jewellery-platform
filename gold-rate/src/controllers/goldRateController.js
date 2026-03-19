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

export async function getGoldPrice(req, res) {
  try {
    const rates = await fetchGoldRates();
    const goldData = rates.international ? {
      price_per_gram_lkr: rates.international.price_per_gram_lkr,
      xauUsd: rates.international.xauUsd,
      currency: rates.international.currency,
      source: rates.international.source,
      timestamp: rates.international.timestamp,
    } : null;
    res.json({ success: true, gold: goldData });
  } catch (err) {
    console.error('Gold price error:', err);
    res.status(502).json({
      success: false,
      message: err?.message ?? 'Failed to fetch gold price',
    });
  }
}

export async function getSilverPrice(req, res) {
  try {
    const rates = await fetchGoldRates();
    const silverData = rates.international ? {
      price_per_gram_lkr: rates.international.silver ? Math.round((rates.international.silver * rates.international.usdToLkr) / 31.1034768) : null,
      xagUsd: rates.international.silver,
      currency: rates.international.currency,
      source: rates.international.source,
      timestamp: rates.international.timestamp,
    } : null;
    res.json({ success: true, silver: silverData });
  } catch (err) {
    console.error('Silver price error:', err);
    res.status(502).json({
      success: false,
      message: err?.message ?? 'Failed to fetch silver price',
    });
  }
}

export async function getPlatinumPrice(req, res) {
  try {
    const rates = await fetchGoldRates();
    const platinumData = rates.international ? {
      price_per_gram_lkr: rates.international.platinum ? Math.round((rates.international.platinum * rates.international.usdToLkr) / 31.1034768) : null,
      xptUsd: rates.international.platinum,
      currency: rates.international.currency,
      source: rates.international.source,
      timestamp: rates.international.timestamp,
    } : null;
    res.json({ success: true, platinum: platinumData });
  } catch (err) {
    console.error('Platinum price error:', err);
    res.status(502).json({
      success: false,
      message: err?.message ?? 'Failed to fetch platinum price',
    });
  }
}
