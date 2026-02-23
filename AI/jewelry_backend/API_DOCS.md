# 📡 Jewelry AI Backend - API Documentation

## Server Information
- **Host**: `0.0.0.0`
- **Port**: `5000`
- **Protocol**: HTTP
- **Base URL**: `http://localhost:5000` or `http://192.168.34.234:5000`

---

## Endpoints

### 1. Health Check
**GET** `/health`

Check if the backend is running.

**Request:**
```http
GET /health HTTP/1.1
Host: localhost:5000
```

**Response (200 OK):**
```json
{
  "status": "ok"
}
```

---

### 2. Generate Image
**POST** `/generate`

Generate an AI image from a text prompt using Hugging Face's Stable Diffusion XL model.

**Request Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "prompt": "a gold ring with emerald stone and diamond accents"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "image_base64": "iVBORw0KGgoAAAANSUhEUgAAAA..."
}
```

**Response (503 - Model Loading):**
```json
{
  "success": false,
  "error": "Model is loading, wait 30 seconds and try again"
}
```

**Response (400 - Missing Prompt):**
```json
{
  "success": false,
  "error": "prompt is required"
}
```

**Response (500 - Server Error):**
```json
{
  "success": false,
  "error": "Error message here"
}
```

---

## cURL Examples

### Test Health Check
```bash
curl http://localhost:5000/health
```

### Generate Image
```bash
curl -X POST http://localhost:5000/generate \
  -H "Content-Type: application/json" \
  -d '{"prompt": "a beautiful gold necklace with pearls"}'
```

---

## Image Generation Parameters

### Prompt Enhancement
The backend automatically enhances your prompt with professional jewelry photography context:
```
Input: "gold ring with sapphire"
Enhanced: "professional jewelry photography, gold ring with sapphire, studio lighting, white background, 8k, photorealistic"
```

### Model Settings
- **Model**: `stabilityai/stable-diffusion-xl-base-1.0`
- **Image Size**: 512x512 pixels
- **Inference Steps**: 30 (quality vs speed tradeoff)
- **Guidance Scale**: 7.5 (how closely to follow the prompt)
- **Timeout**: 120 seconds

---

## Response Format

### Image as Base64
The image is returned as base64-encoded PNG data. To use in Flutter:

```dart
import 'dart:convert';

// From API response
String imageBase64 = data["image_base64"];

// Decode and display
Image.memory(
  base64Decode(imageBase64),
  fit: BoxFit.cover,
)
```

---

## Error Handling

| Status Code | Meaning | Solution |
|------------|---------|----------|
| 200 | Success | Image generated |
| 400 | Bad Request | Missing or empty prompt |
| 503 | Service Unavailable | Model loading - wait 30s and retry |
| 500 | Server Error | Check Flask terminal for details |

---

## Timing Expectations

| Scenario | Time |
|----------|------|
| Health check | < 1 second |
| First image generation | 30-60 seconds |
| Subsequent generations | 10-20 seconds |
| Model warm-up time | ~30 seconds after server start |

---

## Environment Variables

```python
HF_TOKEN = "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"
HF_URL = "https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0"
```

---

## CORS Headers

The backend includes CORS headers to allow requests from Flutter apps:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, OPTIONS
Access-Control-Allow-Headers: Content-Type
```

---

## Python Dependencies

```
Flask==2.3.3          # Web framework
flask-cors==4.0.0     # Cross-origin resource sharing
requests==2.31.0      # HTTP client for Hugging Face API
```

---

## Testing Commands

### Test in Browser (macOS)
```bash
# Health check
open http://localhost:5000/health

# View in browser
curl http://localhost:5000/health | json_pp
```

### Test with Python
```python
import requests
import base64
from PIL import Image
from io import BytesIO

response = requests.post(
    'http://localhost:5000/generate',
    json={'prompt': 'a gold ring'}
)

if response.status_code == 200:
    data = response.json()
    if data['success']:
        # Decode and save image
        image_bytes = base64.b64decode(data['image_base64'])
        image = Image.open(BytesIO(image_bytes))
        image.save('jewelry.png')
```

---

## Security Notes

⚠️ **For Development Only**
- Debug mode is enabled (`debug=True`)
- CORS is open to all origins
- Token is stored in plain text

**For Production:**
1. Disable debug mode
2. Restrict CORS origins
3. Use environment variables for tokens
4. Add authentication layer
5. Use HTTPS
6. Add rate limiting

---

## Architecture Diagram

```
┌─────────────────┐
│   Flutter App   │
└────────┬────────┘
         │
    POST /generate
    {"prompt": "..."}
         │
         ↓
┌─────────────────┐
│  Flask Server   │
│  (app.py)       │
└────────┬────────┘
         │
  HTTP to Hugging Face
         │
         ↓
┌──────────────────────┐
│  Hugging Face API    │
│  Stable Diffusion XL │
└──────────────────────┘
```

---

**Last Updated**: February 23, 2026

