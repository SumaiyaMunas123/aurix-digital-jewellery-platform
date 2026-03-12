// API Configuration
const API_BASE_URL = 'http://localhost:5000/api';

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
        ...options.headers,
      },
      ...options,
    });

    // Handle non-200 responses
    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(errorData.error || `API error: ${response.statusText}`);
    }

    return await response.json();
  } catch (error) {
    console.error('API Error:', error);
    throw error;
  }
};

// ============ AUTH ENDPOINTS ============

/**
 * User signup
 * @param {string} email - User email
 * @param {string} password - User password
 * @param {string} user_type - 'customer' or 'jeweller'
 * @param {object} metadata - Additional user info
 * @returns {Promise} User data and session
 */
export const signup = (email, password, user_type, metadata = {}) => {
  return apiCall('/auth/signup', {
    method: 'POST',
    body: JSON.stringify({
      email,
      password,
      user_type,
      metadata,
    }),
  });
};

/**
 * User login
 * @param {string} email - User email
 * @param {string} password - User password
 * @returns {Promise} User data and session token
 */
export const login = (email, password) => {
  return apiCall('/auth/login', {
    method: 'POST',
    body: JSON.stringify({ email, password }),
  });
};

// ============ PRODUCT ENDPOINTS ============

/**
 * Create a new product
 * @param {object} productData - Product details
 * @returns {Promise} Created product
 */
export const createProduct = (productData) => {
  return apiCall('/products', {
    method: 'POST',
    body: JSON.stringify(productData),
  });
};

/**
 * Get all products
 * @returns {Promise} List of all products
 */
export const getAllProducts = () => {
  return apiCall('/products', {
    method: 'GET',
  });
};

/**
 * Get a single product by ID
 * @param {string} productId - Product ID
 * @returns {Promise} Product details
 */
export const getProductById = (productId) => {
  return apiCall(`/products/${productId}`, {
    method: 'GET',
  });
};

/**
 * Update a product
 * @param {string} productId - Product ID
 * @param {object} updateData - Fields to update
 * @returns {Promise} Updated product
 */
export const updateProduct = (productId, updateData) => {
  return apiCall(`/products/${productId}`, {
    method: 'PUT',
    body: JSON.stringify(updateData),
  });
};

/**
 * Delete a product
 * @param {string} productId - Product ID
 * @returns {Promise} Success message
 */
export const deleteProduct = (productId) => {
  return apiCall(`/products/${productId}`, {
    method: 'DELETE',
  });
};

// ============ ADMIN ENDPOINTS ============

/**
 * Get all pending jewellers (for approval)
 * @returns {Promise} List of pending jewellers
 */
export const getPendingJewellers = () => {
  return apiCall('/admin/jewellers/pending', {
    method: 'GET',
  });
};

/**
 * Get all jewellers with their statuses
 * @returns {Promise} List of all jewellers
 */
export const getAllJewellers = () => {
  return apiCall('/admin/jewellers', {
    method: 'GET',
  });
};

/**
 * Get details for a specific jeweller
 * @param {string} jewellerId - Jeweller ID
 * @returns {Promise} Jeweller details and status
 */
export const getJewellerById = (jewellerId) => {
  return apiCall(`/admin/jewellers/${jewellerId}`, {
    method: 'GET',
  });
};

/**
 * Approve a jeweller registration
 * @param {string} jewellerId - Jeweller ID
 * @param {object} approvalData - Additional approval data
 * @returns {Promise} Success message
 */
export const approveJeweller = (jewellerId, approvalData = {}) => {
  return apiCall(`/admin/jewellers/${jewellerId}/approve`, {
    method: 'POST',
    body: JSON.stringify(approvalData),
  });
};

/**
 * Reject a jeweller registration
 * @param {string} jewellerId - Jeweller ID
 * @param {string} reason - Reason for rejection
 * @returns {Promise} Success message
 */
export const rejectJeweller = (jewellerId, reason = '') => {
  return apiCall(`/admin/jewellers/${jewellerId}/reject`, {
    method: 'POST',
    body: JSON.stringify({ reason }),
  });
};

/**
 * Check a jeweller's approval status
 * @param {string} jewellerId - Jeweller ID
 * @returns {Promise} Status information
 */
export const getJewellerStatus = (jewellerId) => {
  return apiCall(`/admin/jewellers/${jewellerId}/status`, {
    method: 'GET',
  });
};

// ============ UTILITY / TESTING ============

/**
 * Get server info and available endpoints
 * @returns {Promise} Server status and endpoints
 */
export const getServerInfo = () => {
  return fetch('http://localhost:5000/')
    .then((res) => res.json())
    .catch((error) => {
      console.error('Failed to connect to server:', error);
      throw error;
    });
};

/**
 * Test database connection
 * @returns {Promise} Database status and user count
 */
export const testDatabaseConnection = () => {
  return fetch('http://localhost:5000/test-db')
    .then((res) => res.json())
    .catch((error) => {
      console.error('Failed to connect to database:', error);
      throw error;
    });
};
