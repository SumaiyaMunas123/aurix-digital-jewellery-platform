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
      warning: 'Could not fetch international gold rate from api.gold-api.com',
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
  try {
    const url = `https://api.gold-api.com/price/${symbol}`;
    const res = await axios.get(url, {
      timeout: 15000,
    });
    const price = res.data?.price;
    if (typeof price !== 'number') {
      throw new Error(`Unexpected response from gold API (${symbol})`);
    }
    return price;
  } catch (err) {
    console.error(`Failed to fetch ${symbol} price from gold-api.com:`, err.message);
    return null;
  }
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
  // Hardcoded fallback since free exchangerate is disabled
  return 300;
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
