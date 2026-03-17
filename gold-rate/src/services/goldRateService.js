import axios from 'axios';
import cheerio from 'cheerio';

const CACHE_TTL_MS = parseInt(process.env.CACHE_TTL_MS ?? '300000', 10); // 5 minutes
let _cache = null;

export async function fetchGoldRates() {
  const now = Date.now();
  if (_cache && now - _cache.fetchedAt < CACHE_TTL_MS) {
    return _cache.data;
  }

  const [international, local_devi] = await Promise.all([
    fetchInternationalGoldRate(),
    fetchDeviGoldRate(),
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
  // 1) Get XAU/USD (price per troy ounce)
  const xauUsd = await getMetalPrice('XAU');

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
    throw new Error('Missing GOLD_API_KEY; set it in .env');
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
  const res = await axios.get('https://api.exchangerate.host/convert', {
    params: { from: 'USD', to: 'LKR', amount: 1 },
    timeout: 15000,
  });

  const rate = res.data?.result;
  if (typeof rate !== 'number') {
    throw new Error('Unable to fetch USD->LKR rate');
  }

  return rate;
}

async function fetchDeviGoldRate() {
  const url = process.env.DEVI_GOLD_URL || 'https://www.deviwatches.com/';

  const res = await axios.get(url, { timeout: 20000, responseType: 'text' });
  const html = res.data;
  const text = cheerio.load(html).text();

  const rates = {
    '24k': extractRate(text, /24\s*[Kk][^\d]*([\d,]+\.?\d*)/g),
    '22k': extractRate(text, /22\s*[Kk][^\d]*([\d,]+\.?\d*)/g),
    '20k': extractRate(text, /20\s*[Kk][^\d]*([\d,]+\.?\d*)/g),
  };

  return {
    source: url,
    timestamp: new Date().toISOString(),
    raw_text: text.slice(0, 2000),
    rates,
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
