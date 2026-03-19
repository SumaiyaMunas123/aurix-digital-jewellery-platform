# AI Backend API Documentation

## Security & Validation

### Rate Limiting
- **Limit**: 10 requests per minute per user
- **Status Code**: 429 Too Many Requests
- **Response includes**: `retryAfter` (seconds to wait)

### Prompt Validation
- **Max length**: 500 characters
- **Requirements**: Non-empty, must be string
- **Blocked patterns**: script, eval, `<script`, `<!--`, onclick

### Timeouts
- **Request timeout**: 120 seconds (2 minutes)
- **On timeout**: 503 Service Unavailable

### Authentication
- Optional: Include `user_id` in request body
- Future: JWT tokens via Authorization header

---

## Endpoints

### `GET /api/ai/health`
Health check endpoint to verify backend status.

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "service": "Aurix AI Backend",
    "status": "operational",
    "endpoints": { ... },
    "features": { ... },
    "timestamp": "2026-03-19T12:00:00Z"
  }
}
```

---

### `POST /api/ai/generate`
Generate jewelry design images from text or sketch.

**Request Body**:
```json
{
  "mode": 0,
  "prompt": "beautiful gold diamond ring",
  "category": "jewelry",
  "material": "gold",
  "karat": "22K",
  "style": "elegant",
  "occasion": "daily wear",
  "budget": "5000-10000",
  "user_id": "user-123",
  "user_type": "customer"
}
```

**Parameters**:
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `mode` | int | ✓ | 0 = text-to-image, 1 = sketch-to-image |
| `prompt` | string | ✓ (mode 0) | Max 500 chars, cannot be empty |
| `sketch` | file | ✓ (mode 1) | Form data, JPEG/PNG/WebP, max 50MB |
| `category` | string | ✗ | jewelry, ring, necklace, etc. |
| `material` | string | ✗ | gold, silver, platinum, etc. |
| `karat` | string | ✗ | 8K, 10K, 14K, 18K, 22K, 24K |
| `style` | string | ✗ | elegant, classic, modern, etc. |
| `occasion` | string | ✗ | daily wear, engagement, wedding, etc. |
| `budget` | string | ✗ | price range or description |
| `user_id` | string | ✗ | user identifier |
| `user_type` | string | ✗ | customer, jeweler, designer |

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "image_url": "https://...",
    "image_base64": "data:image/png;base64,...",
    "sketch_url": null,
    "design": {
      "id": "design-uuid",
      "user_id": "user-123",
      "user_type": "customer",
      "prompt": "beautiful gold diamond ring",
      "style_params": { ... },
      "image_url": "https://...",
      "sketch_url": null,
      "generation_mode": 0,
      "status": "completed",
      "created_at": "2026-03-19T12:00:00Z"
    },
    "mode": 0,
    "timestamp": "2026-03-19T12:00:00Z"
  }
}
```

**Error Responses**:

**400 Bad Request** - Invalid input:
```json
{
  "success": false,
  "error": "prompt exceeds maximum length of 500 characters",
  "timestamp": "2026-03-19T12:00:00Z"
}
```

**429 Too Many Requests** - Rate limit exceeded:
```json
{
  "success": false,
  "error": "Too many requests. Please try again later.",
  "retryAfter": 45,
  "timestamp": "2026-03-19T12:00:00Z"
}
```

**503 Service Unavailable** - Timeout or model loading:
```json
{
  "success": false,
  "error": "Request timeout. Please try again.",
  "timestamp": "2026-03-19T12:00:00Z"
}
```

---

## Response Contract

All API responses follow this structure:

```json
{
  "success": boolean,
  "data": object | null,
  "error": string | null,
  "timestamp": "ISO-8601 datetime"
}
```

### Key Guarantees
- ✅ All responses include `success` field (boolean)
- ✅ Successful responses include `data` object
- ✅ Error responses include `error` string
- ✅ All responses include `timestamp`
- ✅ HTTP status codes match semantics (200, 400, 429, 503)

---

## Example: cURL

```bash
# Text-to-image generation
curl -X POST http://localhost:7000/api/ai/generate \
  -H "Content-Type: application/json" \
  -d '{
    "mode": 0,
    "prompt": "gold diamond engagement ring",
    "user_id": "user-123",
    "material": "gold",
    "karat": "18K"
  }'

# Sketch-to-image generation
curl -X POST http://localhost:7000/api/ai/generate \
  -F "mode=1" \
  -F "sketch=@sketch.jpg" \
  -F "user_id=user-123" \
  -F "material=gold"
```

---

## Security Best Practices

1. **Rate Limiting**: Client-side debouncing + server-side rate limits (10/min)
2. **Prompt Validation**: Max 500 chars, no HTML/scripts
3. **File Uploads**: Max 50MB, JPEG/PNG/WebP only, stored in isolated paths
4. **Error Messages**: Generic messages in production, detailed logs server-side
5. **User Isolation**: Paths include user_id (anonymous users get anonymous-TIMESTAMP)
6. **Timeout Protection**: 2-minute timeout prevents long-running requests

---

## Future Enhancements

- [ ] JWT token validation in Authorization header
- [ ] Stricter prompt filtering (content moderation)
- [ ] Per-user quota limits (e.g., 100 designs/month)
- [ ] Webhook notifications on completion
- [ ] Batch generation support
