# Aurix Gold Rate Microservice

This microservice provides real-time precious metals pricing (gold, silver, platinum) for the Aurix jewellery platform.

## Setup

1. Install dependencies:
   ```bash
   npm install
   ```

2. Configure environment variables in `.env`:
   ```
   GOLD_API_KEY=your_goldapi_key
   PORT=6000
   ```

3. Start the service:
   ```bash
   npm start
   ```

## API Endpoints

### Get All Rates
- **GET** `/api/gold-rate`
- Returns international and local rates for all metals

### Get Gold Price
- **GET** `/api/gold-rate/gold`
- Returns gold price per gram in LKR and USD

### Get Silver Price
- **GET** `/api/gold-rate/silver`
- Returns silver price per gram in LKR and USD

### Get Platinum Price
- **GET** `/api/gold-rate/platinum`
- Returns platinum price per gram in LKR and USD

## Response Format

```json
{
  "success": true,
  "gold": {
    "price_per_gram_lkr": 51534,
    "xauUsd": 5009.005,
    "currency": "LKR",
    "source": "goldapi.io",
    "timestamp": "2026-03-18T06:29:45.248Z"
  }
}
```

## Integration with Frontend

The frontend can call these endpoints directly:

```javascript
// Get gold price
fetch('http://localhost:6000/api/gold-rate/gold')
  .then(res => res.json())
  .then(data => console.log(data.gold.price_per_gram_lkr));
```

## Caching

Rates are cached for 5 minutes to avoid excessive API calls. Configure `CACHE_TTL_MS` in `.env` to change this.