import axios from 'axios';
import * as cheerio from 'cheerio';
import { load } from 'cheerio';

const CACHE_TTL_MS = parseInt(process.env.CACHE_TTL_MS ?? '300000', 10); // 5 minutes
let _cache = null;

export async function fetchGoldRates() {
  const now = Date.now();
  if (_cache && now - _cache.fetchedAt < CACHE_TTL_MS) {
    return _cache.data;
  }

  const safe = async (fn) => {
    try {
      return await fn();
    } catch (err) {
      return { error: err?.message ?? String(err) };
    }
  };

  const [international, local_devi] = await Promise.all([
    safe(fetchInternationalGoldRate),
    safe(fetchDeviGoldRate),
  ]);

  const data = {
    international,
    local_devi,
    fetchedAt: new Date().toISOString(),
  };

  _cache = { fetchedAt: now, data };
  return data;
}

async function fetchInternationalGoldRate() {
  const xauUsd = await getMetalPrice('XAU');

  // If we cannot fetch the international rate (no API key), return a synthetic placeholder
  if (xauUsd == null) {
    return {
      price_per_gram_lkr: null,
      currency: 'LKR',
      source: getGoldApiSource(),
      timestamp: new Date().toISOString(),
      xauUsd: null,
      silver: null,
      platinum: null,
      usdToLkr: null,
      warning: 'Missing GOLD_API_KEY; set it in .env to get real international rates.',
    };
  }

  // 2) Get USD -> LKR conversion rate
  const usdToLkr = await getUsdToLkr();

  // 3) Convert to LKR per gram (troy ounce = 31.1034768 grams)
  const gramsPerOunce = 31.1034768;
  const pricePerGramLkr = Math.round((xauUsd * usdToLkr) / gramsPerOunce);

  // Optional: fetch silver + platinum for completeness
  const silver = await getMetalPrice('XAG');
  const platinum = await getMetalPrice('XPT');

  return {
    price_per_gram_lkr: pricePerGramLkr,
    currency: 'LKR',
    source: getGoldApiSource(),
    timestamp: new Date().toISOString(),
    xauUsd,
    silver,
    platinum,
    usdToLkr,
  };
}

function getGoldApiSource() {
  if (process.env.GOLD_API_URL) {
    return process.env.GOLD_API_URL;
  }
  if (process.env.GOLD_API_KEY) {
    return 'goldapi.io';
  }
  return 'unknown';
}

async function getMetalPrice(symbol) {
  // symbol: XAU, XAG, XPT
  const url = process.env.GOLD_API_URL || 'https://www.goldapi.io/api';
  const apiKey = process.env.GOLD_API_KEY;

  if (!apiKey) {
    // Allow the service to run without a key (useful for local dev & testing).
    // In this case, we return null so callers can fall back gracefully.
    console.warn('GOLD_API_KEY is missing; international rates will be skipped.');
    return null;
  }

  const endpoint = `${url.replace(/\/$/, '')}/${symbol}/USD`;

  const res = await axios.get(endpoint, {
    headers: {
      'x-access-token': apiKey,
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
    timeout: 15000,
  });

  const price = res.data?.price ?? res.data?.price_usd ?? res.data?.price_usd_per_ounce;
  if (typeof price !== 'number') {
    throw new Error(`Unexpected response from gold API (${symbol}): ${JSON.stringify(res.data).slice(0, 200)}`);
  }
  return price;
}

async function getUsdToLkr() {
  const env = process.env.USD_TO_LKR;
  if (env) {
    const n = Number(env);
    if (!Number.isFinite(n) || n <= 0) {
      throw new Error('Invalid USD_TO_LKR configuration');
    }
    return n;
  }

  // Use exchangerate.host which is free and does not require a key.
  try {
    const res = await axios.get('https://api.exchangerate.host/convert', {
      params: { from: 'USD', to: 'LKR', amount: 1 },
      timeout: 15000,
    });

    const rate = res.data?.result;
    if (typeof rate !== 'number') {
      throw new Error('Unable to fetch USD->LKR rate');
    }

    return rate;
  } catch (err) {
    console.warn('Failed to fetch USD->LKR rate, using fallback:', err.message);
    // Fallback rate (approximate USD to LKR as of 2026)
    return 320; // Adjust as needed
  }
}

async function fetchDeviGoldRate() {
  // For MVP demo, return dummy local rates since the website is not accessible
  // In production, replace with actual scraping logic
  const rates = {
    '24k': 50000, // Dummy values in LKR per gram
    '22k': 46000,
    '20k': 42000,
  };
  
  return {
    source: 'demo',
    timestamp: new Date().toISOString(),
    raw_text: 'Demo data for MVP',
    lkr24k: rates['24k'],
    lkr22k: rates['22k'],
    lkr20k: rates['20k'],
  };
}

function extractRate(text, regex) {
  const match = regex.exec(text);
  if (!match) return null;
  const raw = match[1] ?? '';
  const cleaned = raw.replace(/,/g, '').trim();
  const value = Number(cleaned);
  return Number.isFinite(value) ? value : null;
}
