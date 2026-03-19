# Frontend to Backend API Integration Guide

This document shows exactly what your Flutter frontend should send to the ai-backend for image generation.

## Backend Endpoints

**Base URL**: `http://localhost:7000` (or your deployed URL)

### 1. Health Check (Optional)
```
GET /api/ai/health
```

**Response**:
```json
{
  "success": true,
  "data": {
    "service": "Aurix AI Backend",
    "model": "stabilityai/stable-diffusion-xl-base-1.0",
    "hf_token_set": true,
    "groq_key_set": true
  }
}
```

---

## 2. Generate Image - Text-to-Image Mode (mode: 0)

**Endpoint**: `POST /api/ai/generate`

**Request Format**: JSON

**Request Body**:
```json
{
  "mode": 0,
  "prompt": "elegant gold engagement ring with diamond",
  "category": "Ring",
  "weight": "2g - 5g",
  "material": "Gold",
  "karat": "22K",
  "style": "Modern",
  "occasion": "Engagement",
  "budget": "LKR 200,000 - 500,000",
  "user_id": "user_12345",
  "user_type": "customer"
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "image_base64": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
    "image_url": "https://supabase.../designs/generated-1710780000000.png",
    "design": {
      "id": "uuid-string",
      "user_id": "user_12345",
      "user_type": "customer",
      "prompt": "elegant gold engagement ring with diamond",
      "image_url": "https://supabase.../designs/generated-1710780000000.png",
      "sketch_url": null,
      "style_params": {
        "category": "Ring",
        "weight": "2g - 5g",
        "material": "Gold",
        "karat": "22K",
        "style": "Modern",
        "occasion": "Engagement",
        "budget": "LKR 200,000 - 500,000"
      },
      "generation_mode": 0,
      "status": "completed",
      "created_at": "2026-03-18T12:00:00Z"
    },
    "mode": 0
  }
}
```

**Dart Example**:
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> generateImageFromText(String prompt) async {
  final url = Uri.parse('http://localhost:7000/api/ai/generate');
  
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'mode': 0,
      'prompt': prompt,
      'category': 'Ring',
      'weight': '2g - 5g',
      'material': 'Gold',
      'karat': '22K',
      'style': 'Modern',
      'occasion': 'Daily Wear',
      'budget': 'LKR 50000',
      'user_id': userId,
      'user_type': 'customer',
    }),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final imageBase64 = data['data']['image_base64'];
    final imageUrl = data['data']['image_url'];
    final design = data['data']['design'];
    
    print('Generated image saved to: $imageUrl');
    print('Design ID: ${design['id']}');
  } else {
    print('Error: ${response.body}');
  }
}
```

---

## 3. Generate Image - Sketch-to-Image Mode (mode: 1)

**Endpoint**: `POST /api/ai/generate`

**Request Format**: `multipart/form-data`

**Fields**:
- `mode` (required): `1`
- `prompt` (optional): Additional instructions for refinement
- `sketch` (required): Image file (JPEG, PNG, or WebP)
- `category`: Ring, Necklace, Bracelet, Earring, etc.
- `weight`: e.g., "2g - 5g"
- `material`: Gold, Silver, Platinum, etc.
- `karat`: 22K, 18K, 14K, etc.
- `style`: Elegant, Modern, Vintage, etc.
- `occasion`: Daily Wear, Party, Wedding, etc.
- `budget`: e.g., "LKR 50,000 - 150,000"
- `user_id`: Your user identifier
- `user_type`: customer, jeweler, admin, etc.

**Response** (same structure as text-to-image, but with `sketch_url`):
```json
{
  "success": true,
  "data": {
    "image_base64": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
    "image_url": "https://supabase.../designs/generated-1710780000000.png",
    "sketch_url": "https://supabase.../sketches/sketch-1710780000000.png",
    "design": {
      "id": "uuid-string",
      "sketch_url": "https://supabase.../sketches/sketch-1710780000000.png",
      "generation_mode": 1,
      ...
    },
    "mode": 1
  }
}
```

**Dart Example**:
```dart
import 'package:http/http.dart' as http;
import 'dart:io';

Future<void> generateImageFromSketch(File sketchFile) async {
  final url = Uri.parse('http://localhost:7000/api/ai/generate');
  
  var request = http.MultipartRequest('POST', url);
  
  // Add fields
  request.fields['mode'] = '1';
  request.fields['prompt'] = 'refine this sketch into a professional design';
  request.fields['category'] = 'Ring';
  request.fields['weight'] = '2g - 5g';
  request.fields['material'] = 'Gold';
  request.fields['karat'] = '22K';
  request.fields['style'] = 'Modern';
  request.fields['occasion'] = 'Engagement';
  request.fields['budget'] = 'LKR 200,000 - 500,000';
  request.fields['user_id'] = userId;
  request.fields['user_type'] = 'customer';
  
  // Add sketch file
  request.files.add(
    await http.MultipartFile.fromPath('sketch', sketchFile.path),
  );
  
  final response = await request.send();
  
  if (response.statusCode == 200) {
    final responseBody = await response.stream.bytesToString();
    final data = jsonDecode(responseBody);
    
    final imageBase64 = data['data']['image_base64'];
    final imageUrl = data['data']['image_url'];
    final sketchUrl = data['data']['sketch_url'];
    
    print('Generated image: $imageUrl');
    print('Sketch saved to: $sketchUrl');
  } else {
    print('Error: ${response.statusCode}');
  }
}
```

---

## Error Handling

### Common Errors

| Status | Error Message | Solution |
|--------|---------------|----------|
| 400 | `prompt is required` | For mode 0, provide a text prompt |
| 400 | `sketch file is required` | For mode 1, upload a sketch file |
| 400 | `File type ... not allowed` | Sketch must be JPEG, PNG, or WebP |
| 400 | `File size exceeds 50MB` | Reduce sketch file size |
| 500 | `HF_TOKEN missing or invalid` | Backend must have valid Hugging Face token |
| 503 | `Model is loading, retry in...` | First request may take 1 minute. Retry. |
| 500 | `Database connection error` | Check Supabase configuration |

### Error Response Format

```json
{
  "success": false,
  "error": "Error message describing what went wrong"
}
```

---

## Performance Notes

| Operation | Time |
|-----------|------|
| First request (model loading) | 45-60 seconds |
| Subsequent text-to-image | 30-45 seconds |
| Subsequent sketch-to-image | 20-40 seconds |
| Output size | 512×512 pixels PNG |

---

## Field References

### Mode
- `0` - Text-to-Image: Generate from text prompt only
- `1` - Sketch-to-Image: Refine uploaded sketch

### Category
- Ring
- Necklace
- Bracelet
- Earring
- Pendant
- Brooch
- Anklet

### Material
- Gold
- Silver
- Platinum
- Diamond
- Pearl
- Gemstone

### Karat (for gold)
- 24K (pure)
- 22K
- 18K
- 14K
- 10K

### Style
- Elegant
- Modern
- Vintage
- Minimalist
- Ornate
- Contemporary
- Traditional

### Occasion
- Daily Wear
- Party
- Wedding
- Engagement
- Formal
- Casual
- Festival

---

## Testing the Endpoints

### Using cURL (Test mode 0)

```bash
curl -X POST http://localhost:7000/api/ai/generate \
  -H "Content-Type: application/json" \
  -d '{
    "mode": 0,
    "prompt": "gold ring with diamonds",
    "category": "Ring",
    "material": "Gold",
    "karat": "22K",
    "user_id": "test-user"
  }' | jq '.'
```

### Using cURL (Test mode 1)

```bash
curl -X POST http://localhost:7000/api/ai/generate \
  -F "mode=1" \
  -F "prompt=refine this sketch" \
  -F "category=Ring" \
  -F "material=Gold" \
  -F "user_id=test-user" \
  -F "sketch=@sketch.jpg" | jq '.'
```

---

## Next Steps

1. ✅ Backend is ready and running
2. ✅ All endpoints operational
3. 📱 Connect your Flutter frontend using the examples above
4. 🧪 Test both modes (text and sketch)
5. 🚀 Deploy to production

Questions? Check the backend logs for detailed error messages!
