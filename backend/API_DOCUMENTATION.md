# Aurix Backend API Documentation

## Overview
- **Base URL**: `http://localhost:5000`
- **API Prefix**: `/api`
- **Database**: Supabase PostgreSQL
- **Authentication**: JWT Bearer Token

---

## Authentication

### Getting a Token
1. Call `POST /api/auth/signup` or `POST /api/auth/login`
2. Response includes `token` field
3. Use token in all protected requests: `Authorization: Bearer <token>`

**Protected Routes Require**:
- Valid JWT token in `Authorization` header
- Correct `role` for role-based endpoints

---

## Response Format

### Success Response (200, 201)
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { /* resource data */ },
  "timestamp": "2026-03-20T10:30:00.000Z"
}
```

### Error Response (4xx, 5xx)
```json
{
  "success": false,
  "message": "Error description",
  "timestamp": "2026-03-20T10:30:00.000Z",
  "details": { /* validation details if applicable */ }
}
```

---

## Auth Endpoints

### 1. Signup
- **POST** `/api/auth/signup`
- **Auth**: ❌ Not required
- **Description**: Register new customer or jeweller account

**Request Body** (Customer):
```json
{
  "email": "customer@example.com",
  "password": "SecurePass123",
  "name": "John Doe",
  "phone": "+94771234567",
  "role": "customer",
  "date_of_birth": "1990-01-15",
  "gender": "male",
  "relationship_status": "single"
}
```

**Request Body** (Jeweller):
```json
{
  "email": "jeweller@example.com",
  "password": "SecurePass123",
  "name": "Jane Smith",
  "phone": "+94771234568",
  "role": "jeweller",
  "business_name": "Gold & Gems",
  "business_registration_number": "BRN-001",
  "certification_document_url": "https://example.com/cert.pdf"
}
```

**Response** (201):
```json
{
  "success": true,
  "message": "Jeweller registered successfully. Application pending admin approval.",
  "data": {
    "user": { "id": "uuid", "email": "...", "role": "jeweller" },
    "requires_verification": true
  }
}
```

---

### 2. Login
- **POST** `/api/auth/login`
- **Auth**: ❌ Not required
- **Description**: Authenticate user and get JWT token

**Request Body**:
```json
{
  "identifier": "customer@example.com",
  "password": "SecurePass123"
}
```

**Response** (200):
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": { "id": "uuid", "email": "...", "role": "customer" },
    "token": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

**Failure Cases**:
- `401`: Invalid credentials
- `403` + `code: JEWELLER_PENDING`: Jeweller account awaiting admin approval
- `403` + `code: JEWELLER_REJECTED`: Jeweller account was rejected
- `403` + `code: EMAIL_NOT_VERIFIED`: Customer email not verified yet

---

### 3. Google Auth
- **POST** `/api/auth/google`
- **Auth**: ❌ Not required
- **Description**: Sign up or sign in with Google

**Request Body**:
```json
{
  "email": "user@gmail.com",
  "name": "User Name",
  "role": "customer",
  "google_id": "google-oauth-id",
  "phone": "+94771234567"
}
```

---

### 4. Request Email Verification
- **POST** `/api/auth/email/request-verification`
- **Auth**: ❌ Not required
- **Description**: Send verification code to customer email

**Request Body**:
```json
{
  "email": "customer@example.com"
}
```

---

### 5. Verify Email Code
- **POST** `/api/auth/email/verify-code`
- **Auth**: ❌ Not required
- **Description**: Verify customer email with code

**Request Body**:
```json
{
  "email": "customer@example.com",
  "code": "123456"
}
```

---

### 6. Logout
- **POST** `/api/auth/logout`
- **Auth**: ✅ Required
- **Description**: Invalidate session (client-side token removal recommended)

---

## Product Endpoints

### 1. Get All Products
- **GET** `/api/products`
- **Auth**: ❌ Not required
- **Query Parameters**:
  - `category`: Filter by category
  - `search`: Search by name or description
  - `min_price`: Minimum price
  - `max_price`: Maximum price

**Response** (200):
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Gold Ring",
      "jeweller": "Gold & Gems",
      "priceLkr": 45000,
      "category": "rings",
      "imageUrl": "https://..."
    }
  ]
}
```

---

### 2. Get Product by ID
- **GET** `/api/products/:id`
- **Auth**: ❌ Not required

---

### 3. Add Product (Jeweller Only)
- **POST** `/api/products`
- **Auth**: ✅ Required (role: `jeweller`)
- **Description**: Create new product listing

**Request Body**:
```json
{
  "name": "Diamond Earrings",
  "description": "Elegant diamond drop earrings",
  "price": 75000,
  "price_mode": "show_price",
  "category": "earrings",
  "metal_type": "Gold",
  "karat": 18,
  "weight_grams": 5.5,
  "making_charge": 3000,
  "image_url": "https://...",
  "stock_quantity": 3
}
```

---

### 4. Update Product (Jeweller Only)
- **PUT** `/api/products/:id`
- **Auth**: ✅ Required (role: `jeweller`)
- **Request Body**: Same as Add Product (partial updates allowed)

---

### 5. Delete Product (Jeweller Only)
- **DELETE** `/api/products/:id`
- **Auth**: ✅ Required (role: `jeweller`)

---

### 6. Toggle Product Visibility (Jeweller Only)
- **PATCH** `/api/products/:id/toggle-visibility`
- **Auth**: ✅ Required (role: `jeweller`)

---

### 7. Get Categories
- **GET** `/api/products/categories`
- **Auth**: ❌ Not required

---

## Admin Endpoints

> **All admin endpoints require authentication and `admin` role**

### 1. Admin Login
- **POST** `/api/admin/login`
- **Auth**: ❌ Not required
- **Description**: Admin-specific login endpoint

**Request Body**:
```json
{
  "email": "admin@aurix.com",
  "password": "SecureAdminPass123"
}
```

---

### 2. Get Pending Jewellers
- **GET** `/api/admin/jewellers/pending`
- **Auth**: ✅ Required (role: `admin`)

**Response** (200):
```json
{
  "success": true,
  "data": {
    "jewellers": [...],
    "count": 5
  }
}
```

---

### 3. Get All Jewellers
- **GET** `/api/admin/jewellers`
- **Auth**: ✅ Required (role: `admin`)
- **Query Parameters**:
  - `status`: Filter by verification_status (pending, approved, rejected)

---

### 4. Get Jeweller Status
- **GET** `/api/admin/jewellers/:jeweller_id/status`
- **Auth**: ✅ Required (role: `admin`)

---

### 5. Approve Jeweller
- **PUT** `/api/admin/jewellers/:jeweller_id/approve`
- **Auth**: ✅ Required (role: `admin`)

---

### 6. Reject Jeweller
- **PUT** `/api/admin/jewellers/:jeweller_id/reject`
- **Auth**: ✅ Required (role: `admin`)

**Request Body**:
```json
{
  "reason": "Documentation incomplete"
}
```

---

### 7. Get Platform Stats
- **GET** `/api/admin/stats`
- **Auth**: ✅ Required (role: `admin`)

**Response** (200):
```json
{
  "success": true,
  "data": {
    "totalCustomers": 120,
    "totalJewellers": 35,
    "approvedJewellers": 28,
    "pendingJewellers": 7,
    "totalProducts": 450
  }
}
```

---

## Chat Endpoints

> **All chat endpoints require authentication**

### 1. Start Chat
- **POST** `/api/chat/start`
- **Auth**: ✅ Required
- **Description**: Start or retrieve existing chat thread

**Request Body**:
```json
{
  "participant_id": "uuid"
}
```

---

### 2. Send Message
- **POST** `/api/chat/send`
- **Auth**: ✅ Required

**Request Body**:
```json
{
  "thread_id": "uuid",
  "message": "Hello, is this product still available?"
}
```

---

### 3. Get Chat Threads
- **GET** `/api/chat/threads/:user_id`
- **Auth**: ✅ Required

---

### 4. Get Messages
- **GET** `/api/chat/:thread_id/messages`
- **Auth**: ✅ Required

---

### 5. Mark as Read
- **POST** `/api/chat/read`
- **Auth**: ✅ Required

**Request Body**:
```json
{
  "thread_id": "uuid"
}
```

---

### 6. Send Quotation
- **POST** `/api/chat/quotation`
- **Auth**: ✅ Required

**Request Body**:
```json
{
  "thread_id": "uuid",
  "product_id": "uuid",
  "quoted_price": 45000,
  "notes": "Customization available"
}
```

---

### 7. Share AI Design
- **POST** `/api/chat/share-design`
- **Auth**: ✅ Required

**Request Body**:
```json
{
  "thread_id": "uuid",
  "design_id": "uuid",
  "design_image_url": "https://..."
}
```

---

## AI Endpoints

### 1. AI Health
- **GET** `/api/ai/health`
- **Auth**: ❌ Not required

---

### 2. Generate Image
- **POST** `/api/ai/generate`
- **Auth**: ❌ Not required (rate limit recommended for production)

**Request Body**:
```json
{
  "prompt": "Gold ring with diamond, modern design"
}
```

---

### 3. AI Chat
- **POST** `/api/ai/chat`
- **Auth**: ❌ Not required

**Request Body**:
```json
{
  "message": "Suggest a gold necklace for wedding"
}
```

---

### 4. AI Suggestions
- **POST** `/api/ai/suggestions`
- **Auth**: ❌ Not required

**Request Body**:
```json
{
  "preferences": "gold, traditional, budget: 50000"
}
```

---

## Gold Rate Endpoint

### Get Current Gold Rates
- **GET** `/gold-rate`
- **Auth**: ❌ Not required
- **Timeout**: 8 seconds
- **Falls back to**: HTTP 504 on timeout, 502 on service unavailable

---

## Error Codes Reference

| Code | Meaning | Action |
|------|---------|--------|
| 400 | Bad Request / Validation failed | Check request body, required fields |
| 401 | Unauthorized | Provide valid JWT token |
| 403 | Forbidden | Not enough permissions for resource |
| 404 | Not found | Resource doesn't exist |
| 500 | Server error | Retry later, contact support |
| 502 | Bad gateway | Upstream service unavailable |
| 504 | Gateway timeout | Upstream service slow/unresponsive |

---

## Testing with Postman

1. **Import collection** from any endpoint and use `Authorization: Bearer <token>` header
2. **Test signup** first to get mail token
3. **Use token** in subsequent requests
4. **Role-based testing**: Use different user roles to test access control

---

## Rate Limiting (Future)
Currently not implemented. Recommended for production:
- Auth endpoints: 5 req/min
- AI endpoints: 10 req/min (per user)
- General endpoints: 100 req/min

---

**Last Updated**: March 2026  
**Version**: 1.0
