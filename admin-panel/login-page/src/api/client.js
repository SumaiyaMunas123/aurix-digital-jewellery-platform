// API Configuration — uses Vite proxy in dev, relative path in production
const API_BASE_URL = '/api';

/**
 * Returns the stored admin JWT token, if any.
 */
const getAuthHeaders = () => {
  const token = localStorage.getItem('adminToken');
  return token ? { Authorization: `Bearer ${token}` } : {};
};

/**
 * Base API call function
 * @param {string} endpoint - The API endpoint
 * @param {object} options - Fetch options (method, headers, body, etc.)
 * @returns {Promise} Response data
 */
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

    // Handle non-200 responses
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

// Auth Endpoints

export const signup = (email, password, user_type, metadata = {}) => {
  return apiCall('/auth/signup', {
    method: 'POST',
    body: JSON.stringify({ email, password, user_type, metadata }),
  });
};

export const login = (email, password) => {
  return apiCall('/auth/login', {
    method: 'POST',
    body: JSON.stringify({ email, password }),
  });
};

// Product Endpoints

export const createProduct = (productData) => {
  return apiCall('/products', {
    method: 'POST',
    body: JSON.stringify(productData),
  });
};

export const getAllProducts = () => {
  return apiCall('/products', { method: 'GET' });
};

export const getProductById = (productId) => {
  return apiCall(`/products/${productId}`, { method: 'GET' });
};

export const updateProduct = (productId, updateData) => {
  return apiCall(`/products/${productId}`, {
    method: 'PUT',
    body: JSON.stringify(updateData),
  });
};

export const deleteProduct = (productId) => {
  return apiCall(`/products/${productId}`, { method: 'DELETE' });
};

// Admin Endpoints

export const getPendingJewellers = () => {
  return apiCall('/admin/jewellers/pending', { method: 'GET' });
};

export const getAllJewellers = () => {
  return apiCall('/admin/jewellers', { method: 'GET' });
};

export const getJewellerById = (jewellerId) => {
  return apiCall(`/admin/jewellers/${jewellerId}`, { method: 'GET' });
};

export const approveJeweller = (jewellerId, approvalData = {}) => {
  return apiCall(`/admin/jewellers/${jewellerId}/approve`, {
    method: 'PUT',
    body: JSON.stringify(approvalData),
  });
};

export const rejectJeweller = (jewellerId, reason = '') => {
  return apiCall(`/admin/jewellers/${jewellerId}/reject`, {
    method: 'PUT',
    body: JSON.stringify({ reason }),
  });
};

export const getJewellerStatus = (jewellerId) => {
  return apiCall(`/admin/jewellers/${jewellerId}/status`, { method: 'GET' });
};

//  Document Endpoints

// Jeweller: save uploaded document URLs
export const saveDocumentUrls = (documents) => {
  return apiCall('/documents/my/save', {
    method: 'POST',
    body: JSON.stringify({ documents }),
  });
};

// Jeweller: get own documents
export const getMyDocuments = () => {
  return apiCall('/documents/my', { method: 'GET' });
};

// Admin: get a specific jeweller's documents
export const getJewellerDocuments = (jewellerId) => {
  return apiCall(`/documents/${jewellerId}`, { method: 'GET' });
};

// Admin: add per-document feedback
export const addDocumentFeedback = (jewellerId, documentKey, feedback) => {
  return apiCall(`/documents/${jewellerId}/feedback`, {
    method: 'POST',
    body: JSON.stringify({ document_key: documentKey, feedback }),
  });
};

// Admin: get admin action logs for a jeweller
export const getAdminActionLogs = (jewellerId) => {
  return apiCall(`/documents/${jewellerId}/logs`, { method: 'GET' });
};

// Utility 

export const getServerInfo = () => {
  return fetch('/').then((res) => res.json());
};