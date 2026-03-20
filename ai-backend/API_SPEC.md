# AI Backend API Documentation

**Last Updated**: 2026-03-20  
**Version**: 1.0  
**Base URL**: `http://localhost:7000`

## Quick Start

### Environment Setup
```bash
npm install
cp .env.example .env
# Update .env with Supabase and HF credentials
npm start
```

### Response Schema (All Endpoints)
Every endpoint returns JSON with this structure:

```json
{
  "success": boolean,
  "data": object | null,
  "message": string (optional, on success),
  "error": string (optional, on error),
  "timestamp": "2026-03-20T04:29:16.537Z"
}
```

Additional fields on specific error status codes:
- **429 Rate Limited**: `retryAfter` (seconds), `retryGuidance` (string)
- **503 Timeout**: `retryGuidance` (string), `timeoutSeconds` (number)

---

## Security & Validation

### Rate Limiting
- **Limit**: 10 requests per minute per user (tracked by user_id or IP)
- **Status Code**: 429 Too Many Requests
- **Response Fields**: `retryAfter` (seconds to wait), `retryGuidance` (client guidance)
- **Example**:
  ```json
  {
    "success": false,
    "error": "Rate limit exceeded. Too many requests.",
    "retryAfter": 45,
    "retryGuidance": "Please wait 45 seconds before retrying.",
    "timestamp": "2026-03-20T04:30:00Z"
  }
  ```

### Prompt Validation
- **Max length**: 500 characters
- **Min length**: 1 character (non-empty)
- **Type**: Must be string
- **Blocked patterns**: script, eval, `<script`, `<!--`, onclick, onerror, javascript:, on*= (regex-based XSS detection)
- **Status Code on violation**: 400 Bad Request

### File Upload Validation
- **File size**: Max 50MB
- **MIME types**: `image/jpeg`, `image/png`, `image/webp` only
- **Extensions**: `.jpg`, `.jpeg`, `.png`, `.webp`
- **Multer storage**: Disk storage in `./temp` with unique filenames
- **Cleanup**: Files deleted in finally block after processing
- **Status Code on violation**: 400 Bad Request

### Generation Parameters Validation
- **Mode**: Must be 0 (text-to-image) or 1 (sketch-to-image)
- **Karat**: If provided, must be one of: 8K, 10K, 14K, 18K, 22K, 24K
- **Material**: If provided, must be one of: gold, silver, platinum, rose-gold, white-gold
- **Style**: If provided, must be one of: elegant, classic, modern, minimalist, ornate, art-deco
- **Status Code on violation**: 400 Bad Request

### Authentication
- **Type**: Optional user context
- **Extract from**: body.user_id, query.user_id, or headers.authorization (Bearer token)
- **Default**: Anonymous requests allowed with req.user = {id: null, type: 'customer', isAuthenticated: false}
- **User Scoping**: Design endpoints validate req.user.id matches design.user_id (returns 403 Forbidden if not owner/admin)

### Timeouts
- **Request timeout**: 120 seconds (2 minutes) per request
- **Status Code on timeout**: 503 Service Unavailable
- **Response includes**: `retryGuidance` with explanation

### Error Codes (HTTP Status)
| Code | Scenario | Details |
|------|----------|---------|
| 200 | Success | Valid response with data |
| 400 | Bad Request | Invalid input, validation failure |
| 401 | Unauthorized | Auth middleware failure |
| 403 | Forbidden | User scoping violation (accessing other user's designs) |
| 404 | Not Found | Resource not found (design ID doesn't exist) |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Server Error | Unexpected error, includes error message |
| 503 | Service Unavailable | Timeout or temporary service issue |

---

## Endpoints

### `GET /api/ai/health`
Health check - verify backend is operational.

**Request**: No parameters

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "service": "Aurix AI Backend",
    "status": "operational",
    "endpoints": {
      "generate": "POST /api/ai/generate",
      "health": "GET /api/ai/health"
    },
    "features": {
      "hf_token_configured": true,
      "supabase_configured": true,
      "groq_key_configured": true
    }
  },
  "message": "Service health check passed",
  "timestamp": "2026-03-20T04:29:16.537Z"
}
```

---

### `POST /api/ai/generate`
Generate jewelry design images from text or sketch input.

**Middleware Chain**: `timeoutHandler(120s)` → `rateLimitAI` → `validatePrompt` → `validateGenerationParams` → controller

**Request Body (JSON for mode 0, FormData for mode 1)**:

**Mode 0 (Text-to-Image):**
```json
{
  "mode": 0,
  "prompt": "beautiful gold diamond ring",
  "category": "ring",
  "material": "gold",
  "karat": "22K",
  "style": "elegant",
  "occasion": "daily wear",
  "budget": "5000-10000",
  "user_id": "user-123",
  "user_type": "customer"
}
```

**Mode 1 (Sketch-to-Image) - FormData:**
```
mode: 1
prompt: "refine my sketch into a professional design"
sketch: [File]
user_id: user-123
user_type: customer
```

**Parameters**:
| Field | Type | Required | Mode | Constraints |
|-------|------|----------|------|-------------|
| `mode` | int | ✓ | both | 0 or 1 |
| `prompt` | string | ✓ (mode 0) | both | 1-500 chars, no XSS patterns |
| `sketch` | file | ✓ (mode 1) | 1 | JPEG/PNG/WebP, max 50MB |
| `category` | string | ✗ | both | e.g., "ring", "necklace" |
| `weight` | string | ✗ | both | e.g., "5g", "10g" |
| `material` | string | ✗ | both | gold, silver, platinum, rose-gold, white-gold |
| `karat` | string | ✗ | both | 8K, 10K, 14K, 18K, 22K, 24K |
| `style` | string | ✗ | both | elegant, classic, modern, minimalist, ornate, art-deco |
| `occasion` | string | ✗ | both | e.g., "daily wear", "engagement" |
| `budget` | string | ✗ | both | free-form text |
| `user_id` | string | ✗ | both | user identifier for tracking |
| `user_type` | string | ✗ | both | customer, jeweler, designer |

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "image_url": "https://mjzqcilffryycowlntcf.supabase.co/storage/v1/object/public/designs/customer/user-123/generated-1710920356000.png",
    "image_base64": "data:image/png;base64,iVBORw0KGgoAAAANS...",
    "sketch_url": null,
    "design": {
      "id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
      "user_id": "user-123",
      "user_type": "customer",
      "prompt": "beautiful gold diamond ring",
      "style_params": {
        "category": "ring",
        "material": "gold",
        "karat": "22K",
        "style": "elegant"
      },
      "image_url": "https://...",
      "sketch_url": null,
      "generation_mode": 0,
      "status": "completed",
      "created_at": "2026-03-20T04:29:16.537Z"
    },
    "mode": 0
  },
  "message": "Image generated successfully",
  "timestamp": "2026-03-20T04:29:20.123Z"
}
```

**Error Responses**:

**400 Bad Request** (Empty prompt):
```json
{
  "success": false,
  "data": null,
  "error": "Prompt cannot be empty",
  "timestamp": "2026-03-20T04:30:00Z"
}
```

**400 Bad Request** (Prompt too long):
```json
{
  "success": false,
  "data": null,
  "error": "Prompt exceeds maximum length of 500 characters. Current: 523",
  "timestamp": "2026-03-20T04:30:00Z"
}
```

**400 Bad Request** (XSS pattern detected):
```json
{
  "success": false,
  "data": null,
  "error": "Prompt contains disallowed content (script/injection attempt)",
  "timestamp": "2026-03-20T04:30:00Z"
}
```

**429 Too Many Requests** (Rate limited):
```json
{
  "success": false,
  "data": null,
  "error": "Rate limit exceeded. Too many requests.",
  "retryAfter": 45,
  "retryGuidance": "Please wait 45 seconds before retrying.",
  "timestamp": "2026-03-20T04:31:00Z"
}
```

**503 Service Unavailable** (Timeout):
```json
{
  "success": false,
  "data": null,
  "error": "Request timeout. Generation took too long.",
  "retryGuidance": "The AI generation request exceeded the 120-second timeout. Please try with a simpler prompt or lower image quality parameters.",
  "timeoutSeconds": 120,
  "timestamp": "2026-03-20T04:31:00Z"
}
```

---

### `GET /api/designs`
Get all designs for a user with pagination.

**Middleware Chain**: `validateUserAuth` → controller

**Query Parameters**:
| Parameter | Type | Required | Default | Notes |
|-----------|------|----------|---------|-------|
| `user_id` | string | ✓ | N/A | User identifier |
| `user_type` | string | ✗ | N/A | Filter by user type |
| `limit` | int | ✗ | 20 | Items per page (1-100) |
| `offset` | int | ✗ | 0 | Pagination offset |

**Request**:
```bash
GET /api/designs?user_id=user-123&limit=10&offset=0
```

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "design-uuid-1",
        "user_id": "user-123",
        "prompt": "gold ring",
        "image_url": "https://...",
        "is_favorite": false,
        "created_at": "2026-03-20T04:29:16Z"
      }
    ],
    "pagination": {
      "limit": 10,
      "offset": 0,
      "total": 5
    }
  },
  "message": "Designs retrieved successfully",
  "timestamp": "2026-03-20T04:29:20Z"
}
```

**Error: 403 Forbidden** (User scoping violation):
```json
{
  "success": false,
  "data": null,
  "error": "Cannot access designs for other users",
  "timestamp": "2026-03-20T04:30:00Z"
}
```

---

### `GET /api/designs/:id`
Get a single design by ID.

**Middleware Chain**: `validateUserAuth` → controller

**Request**:
```bash
GET /api/designs/design-uuid-1
```

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "id": "design-uuid-1",
    "user_id": "user-123",
    "prompt": "gold diamond ring",
    "image_url": "https://...",
    "is_favorite": false,
    "created_at": "2026-03-20T04:29:16Z"
  },
  "message": "Design retrieved successfully",
  "timestamp": "2026-03-20T04:29:20Z"
}
```

**Error: 404 Not Found**:
```json
{
  "success": false,
  "data": null,
  "error": "Design not found",
  "timestamp": "2026-03-20T04:30:00Z"
}
```

**Error: 403 Forbidden** (Not owner):
```json
{
  "success": false,
  "data": null,
  "error": "Cannot access this design",
  "timestamp": "2026-03-20T04:30:00Z"
}
```

---

### `DELETE /api/designs/:id`
Delete a design by ID (owner only).

**Middleware Chain**: `validateUserAuth` → controller

**Request**:
```bash
DELETE /api/designs/design-uuid-1
```

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "id": "design-uuid-1",
    "deleted": true
  },
  "message": "Design deleted successfully",
  "timestamp": "2026-03-20T04:29:20Z"
}
```

**Error: 403 Forbidden** (Not owner):
```json
{
  "success": false,
  "data": null,
  "error": "Cannot delete designs created by other users",
  "timestamp": "2026-03-20T04:30:00Z"
}
```

---

### `PATCH /api/designs/:id/favorite`
Toggle favorite status of a design (owner only).

**Middleware Chain**: `validateUserAuth` → controller

**Request**:
```bash
PATCH /api/designs/design-uuid-1/favorite
```

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "id": "design-uuid-1",
    "is_favorite": true
  },
  "message": "Design favorite status updated",
  "timestamp": "2026-03-20T04:29:20Z"
}
```

---

### `POST /api/designs/generate-styled`
Generate image with style parameters (user-friendly wrapper).

**Middleware Chain**: `validateUserAuth` → `timeoutHandler` → `rateLimitAI` → `validatePrompt` → `validateGenerationParams` → controller

**Request Body (JSON)**:
```json
{
  "prompt": "gold ring with gemstones",
  "user_id": "user-123",
  "user_type": "customer",
  "style": {
    "material": "gold",
    "jewelry_type": "ring",
    "gemstone": "diamond",
    "style": "elegant",
    "finish": "matte"
  }
}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "image_base64": "data:image/png;base64,...",
    "image_url": "https://...",
    "design": {
      "id": "design-uuid",
      "user_id": "user-123",
      "prompt": "gold ring with gemstones",
      "image_url": "https://...",
      "created_at": "2026-03-20T04:29:16Z"
    }
  },
  "message": "Styled image generated successfully",
  "timestamp": "2026-03-20T04:29:20Z"
}
```

---

### `POST /api/designs/sketch-to-image`
Process a sketch and generate refined design image.

**Middleware Chain**: `validateUserAuth` → `timeoutHandler` → `rateLimitAI` → `validatePrompt` → controller

**Request Body (JSON)**:
```json
{
  "prompt": "refine this sketch",
  "sketch_base64": "data:image/png;base64,iVBORw0KGgoAAAA...",
  "user_id": "user-123",
  "user_type": "customer"
}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "image_base64": "data:image/png;base64,...",
    "image_url": "https://...",
    "sketch_url": "https://...",
    "design": {
      "id": "design-uuid",
      "user_id": "user-123",
      "prompt": "refine this sketch",
      "image_url": "https://...",
      "sketch_url": "https://...",
      "created_at": "2026-03-20T04:29:16Z"
    }
  },
  "message": "Sketch processed and design generated successfully",
  "timestamp": "2026-03-20T04:29:20Z"
}
```

**Error: 400 Bad Request** (Invalid base64):
```json
{
  "success": false,
  "data": null,
  "error": "Invalid base64 format. Expected: data:image/[type];base64,[data]",
  "timestamp": "2026-03-20T04:30:00Z"
}
```

---

## Example: cURL

### Health Check
```bash
curl -X GET http://localhost:7000/api/ai/health
```

### Text-to-Image Generation
```bash
curl -X POST http://localhost:7000/api/ai/generate \
  -H "Content-Type: application/json" \
  -d '{
    "mode": 0,
    "prompt": "elegant gold diamond ring",
    "user_id": "user-123",
    "material": "gold",
    "karat": "18K"
  }'
```

### Sketch-to-Image Generation
```bash
curl -X POST http://localhost:7000/api/ai/generate \
  -F "mode=1" \
  -F "prompt=refine this sketch" \
  -F "sketch=@sketch.jpg" \
  -F "user_id=user-123"
```

### Get User Designs
```bash
curl -X GET 'http://localhost:7000/api/designs?user_id=user-123&limit=10'
```

### Delete Design
```bash
curl -X DELETE http://localhost:7000/api/designs/design-uuid-1
```

---

## Architecture

### Middleware Stack
```
Request
  ├─ validateUserAuth (extract req.user context)
  ├─ (route-specific middleware)
  │  ├─ timeoutHandler (120s timeout)
  │  ├─ rateLimitAI (10/min per user)
  │  ├─ validatePrompt (1-500 chars, XSS check)
  │  └─ validateGenerationParams (mode, karat, etc)
  ├─ Controller (business logic)
  │  └─ sendSuccess/sendError (consistent response format)
  └─ Response (200, 400, 403, 404, 429, 500, 503)
```

### File Storage
- **Provider**: Supabase Storage bucket "designs"
- **Path Structure**: `{user_type}/{user_id}/{file-type}-{timestamp}.{ext}`
- **Cleanup**: Temp files deleted in finally block after upload
- **Permissions**: Public read (via signed URLs when needed)

### User Scoping
- All design endpoints check: `req.user.id === design.user_id` OR `req.user.type === 'admin'`
- Violations return 403 Forbidden
- Ensures users can only access/modify their own designs

### Validation Chain
1. **Input validation**: Type, format, length checks
2. **Parameter validation**: Allowed values (karat, material, style)
3. **File validation**: Size, MIME type, extension
4. **User scoping**: Ownership verification for data operations

---

## Security Best Practices

✅ **Rate Limiting**: Client and server-side protection  
✅ **Prompt Filtering**: XSS pattern detection, length limits  
✅ **File Uploads**: MIME type validation, size limits  
✅ **User Isolation**: Paths include user_id, storage scoped by user  
✅ **Error Messages**: Generic in responses, detailed in logs  
✅ **Timeout Protection**: 2-minute timeout prevents resource exhaustion  
✅ **User Scoping**: Design operations validated against owner  
✅ **Cleanup**: Temporary files guaranteed cleanup via finally blocks  

---

## Development

### Running Locally
```bash
cd ai-backend
npm install
npm start
# Server runs on http://localhost:7000
```

### Environment Variables
```env
SUPABASE_URL=https://...
SUPABASE_ANON_KEY=...
SUPABASE_SERVICE_ROLE_KEY=...
HF_TOKEN=hf_...
GROQ_API_KEY=gsk_...
PORT=7000
```

### Project Structure
```
src/
├── config/          # Supabase, HF client config
├── controllers/     # Business logic
├── middleware/      # Auth, validation, rate limiting
├── routes/          # API endpoints
└── utils/           # Helpers, storage, response formatting
```

---

## Status & Support

- ✅ Text-to-image generation (depends on HF Inference API access)
- ✅ Sketch-to-image generation
- ✅ Rate limiting (10 req/min)
- ✅ User isolation & scoping
- ✅ Comprehensive validation
- ✅ Consistent response schema
- 🔄 Webhook notifications (planned)
- 🔄 Batch generation (planned)

For issues or questions, check server logs: `npm start`
