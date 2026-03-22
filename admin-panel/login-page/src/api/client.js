// API Configuration — uses Vite proxy in dev, relative path in production
const API_BASE_URL = '/api';

const getAuthHeaders = () => {
  const token = localStorage.getItem('adminToken');
  return token ? { Authorization: `Bearer ${token}` } : {};
};

export const apiCall = async (endpoint, options = {}) => {
  try {
    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
      headers: {
        'Content-Type': 'application/json',
        ...getAuthHeaders(),
        ...options.headers,
      },
      ...options,
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(errorData.message || errorData.error || `API error: ${response.statusText}`);
    }

    return await response.json();
  } catch (error) {
    console.error('API Error:', error);
    throw error;
  }
};

// ── AUTH ─────────────────────────────────────────────────────
export const signup = (email, password, user_type, metadata = {}) =>
  apiCall('/auth/signup', { method: 'POST', body: JSON.stringify({ email, password, user_type, metadata }) });

export const login = (email, password) =>
  apiCall('/auth/login', { method: 'POST', body: JSON.stringify({ email, password }) });

// ── JEWELLER: PRODUCT ENDPOINTS ──────────────────────────────
export const createProduct = (productData) =>
  apiCall('/products', { method: 'POST', body: JSON.stringify(productData) });

export const getAllProducts = (filters = {}) => {
  const params = new URLSearchParams(filters).toString();
  return apiCall(`/products${params ? `?${params}` : ''}`, { method: 'GET' });
};

export const getProductById = (productId) =>
  apiCall(`/products/${productId}`, { method: 'GET' });

export const updateProduct = (productId, updateData) =>
  apiCall(`/products/${productId}`, { method: 'PUT', body: JSON.stringify(updateData) });

export const deleteProduct = (productId) =>
  apiCall(`/products/${productId}`, { method: 'DELETE' });

export const toggleProductVisibility = (productId) =>
  apiCall(`/products/${productId}/toggle-visibility`, { method: 'PATCH' });

export const getJewellerProducts = (jewellerId) =>
  apiCall(`/products/jeweller/${jewellerId}`, { method: 'GET' });

export const getCategories = () =>
  apiCall('/products/categories', { method: 'GET' });

// ── ADMIN: JEWELLER ENDPOINTS ────────────────────────────────
export const getPendingJewellers = () =>
  apiCall('/admin/jewellers/pending', { method: 'GET' });

export const getAllJewellers = (status = '') =>
  apiCall(`/admin/jewellers${status ? `?status=${status}` : ''}`, { method: 'GET' });

export const getJewellerById = (jewellerId) =>
  apiCall(`/admin/jewellers/${jewellerId}`, { method: 'GET' });

export const approveJeweller = (jewellerId, approvalData = {}) =>
  apiCall(`/admin/jewellers/${jewellerId}/approve`, { method: 'PUT', body: JSON.stringify(approvalData) });

export const rejectJeweller = (jewellerId, reason = '') =>
  apiCall(`/admin/jewellers/${jewellerId}/reject`, { method: 'PUT', body: JSON.stringify({ reason }) });

export const getJewellerStatus = (jewellerId) =>
  apiCall(`/admin/jewellers/${jewellerId}/status`, { method: 'GET' });

// ── ADMIN: PRODUCT MANAGEMENT ENDPOINTS ─────────────────────

// GET /api/admin/products/stats
// Returns: { stats: { total, approved, pending, flagged, rejected }, topViewed, topSold }
export const adminGetProductStats = () =>
  apiCall('/admin/products/stats', { method: 'GET' });

// GET /api/admin/products?search=&category=&admin_status=&is_active=&page=&limit=
// Returns: { products: [...], count, page, limit, totalPages }
export const adminGetAllProducts = (filters = {}) => {
  const params = new URLSearchParams(filters).toString();
  return apiCall(`/admin/products${params ? `?${params}` : ''}`, { method: 'GET' });
};

// GET /api/admin/products/:id
// Returns: { product: { ...fields, jeweller: { business_name, name, ... } } }
export const adminGetProductById = (productId) =>
  apiCall(`/admin/products/${productId}`, { method: 'GET' });

// PATCH /api/admin/products/:id/approve
// Returns: { product: updated } — 400 if stock_quantity = 0
export const adminApproveProduct = (productId) =>
  apiCall(`/admin/products/${productId}/approve`, { method: 'PATCH' });

// PATCH /api/admin/products/:id/reject
// Body (optional): { reason: "..." }
// Returns: { product: updated }
export const adminRejectProduct = (productId, reason = '') =>
  apiCall(`/admin/products/${productId}/reject`, {
    method: 'PATCH',
    body: JSON.stringify({ reason }),
  });

// DELETE /api/admin/products/:id
// Returns: { success: true }
export const adminDeleteProduct = (productId) =>
  apiCall(`/admin/products/${productId}`, { method: 'DELETE' });

// PATCH /api/admin/products/:id/visibility
// Body: { is_active: true/false } — omit to toggle
// Returns: { product: updated }
export const adminToggleProductVisibility = (productId, is_active) =>
  apiCall(`/admin/products/${productId}/visibility`, {
    method: 'PATCH',
    body: is_active !== undefined ? JSON.stringify({ is_active }) : undefined,
  });

// GET /api/admin/jewellers/:jeweller_id/products
// Returns: { products: [...], count }
export const adminGetProductsByJeweller = (jewellerId) =>
  apiCall(`/admin/jewellers/${jewellerId}/products`, { method: 'GET' });

// ── DOCUMENTS ────────────────────────────────────────────────
export const saveDocumentUrls = (documents) =>
  apiCall('/documents/my/save', { method: 'POST', body: JSON.stringify({ documents }) });

export const getMyDocuments = () =>
  apiCall('/documents/my', { method: 'GET' });

export const getJewellerDocuments = (jewellerId) =>
  apiCall(`/documents/${jewellerId}`, { method: 'GET' });

export const addDocumentFeedback = (jewellerId, documentKey, feedback) =>
  apiCall(`/documents/${jewellerId}/feedback`, {
    method: 'POST',
    body: JSON.stringify({ document_key: documentKey, feedback }),
  });

export const getAdminActionLogs = (jewellerId) =>
  apiCall(`/documents/${jewellerId}/logs`, { method: 'GET' });

// ── UTILITY ──────────────────────────────────────────────────
export const getServerInfo = () => fetch('/').then(res => res.json());