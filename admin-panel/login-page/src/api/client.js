const DEFAULT_PROD_API_BASE_URL =
  "https://aurix-digital-jewellery-platform-1.onrender.com/api";

const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL ||
  (import.meta.env.DEV ? "/api" : DEFAULT_PROD_API_BASE_URL);

const getAuthHeaders = () => {
  const token = localStorage.getItem("adminToken");
  return token ? { Authorization: `Bearer ${token}` } : {};
};

export const apiCall = async (endpoint, options = {}) => {
  try {
    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
      headers: {
        "Content-Type": "application/json",
        ...getAuthHeaders(),
        ...options.headers,
      },
      ...options,
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(
        errorData.message ||
          errorData.error ||
          `API error: ${response.statusText}`,
      );
    }

    return await response.json();
  } catch (error) {
    console.error("API Error:", error);
    throw error;
  }
};

// Auth
export const signup = (email, password, user_type, metadata = {}) =>
  apiCall("/auth/signup", {
    method: "POST",
    body: JSON.stringify({ email, password, user_type, metadata }),
  });

export const login = (email, password) =>
  apiCall("/auth/login", {
    method: "POST",
    body: JSON.stringify({ email, password }),
  });

// Jeweller: Products Endpoints
export const createProduct = (productData) =>
  apiCall("/products", { method: "POST", body: JSON.stringify(productData) });

export const getAllProducts = (filters = {}) => {
  const params = new URLSearchParams(filters).toString();
  return apiCall(`/products${params ? `?${params}` : ""}`, { method: "GET" });
};

export const getProductById = (productId) =>
  apiCall(`/products/${productId}`, { method: "GET" });

export const updateProduct = (productId, updateData) =>
  apiCall(`/products/${productId}`, {
    method: "PUT",
    body: JSON.stringify(updateData),
  });

export const deleteProduct = (productId) =>
  apiCall(`/products/${productId}`, { method: "DELETE" });

export const toggleProductVisibility = (productId) =>
  apiCall(`/products/${productId}/toggle-visibility`, { method: "PATCH" });

export const getJewellerProducts = (jewellerId) =>
  apiCall(`/products/jeweller/${jewellerId}`, { method: "GET" });

export const getCategories = () =>
  apiCall("/products/categories", { method: "GET" });

// Admin: Jeweller Endpoints
export const getPendingJewellers = () =>
  apiCall("/admin/jewellers/pending", { method: "GET" });

export const getAllJewellers = (status = "") =>
  apiCall(`/admin/jewellers${status ? `?status=${status}` : ""}`, {
    method: "GET",
  });

export const getJewellerById = (jewellerId) =>
  apiCall(`/admin/jewellers/${jewellerId}`, { method: "GET" });

export const approveJeweller = (jewellerId, approvalData = {}) =>
  apiCall(`/admin/jewellers/${jewellerId}/approve`, {
    method: "PUT",
    body: JSON.stringify(approvalData),
  });

export const rejectJeweller = (jewellerId, reason = "") =>
  apiCall(`/admin/jewellers/${jewellerId}/reject`, {
    method: "PUT",
    body: JSON.stringify({ reason }),
  });

export const getJewellerStatus = (jewellerId) =>
  apiCall(`/admin/jewellers/${jewellerId}/status`, { method: "GET" });

// Product Management Endpoints for Admin

// GET /api/admin/products/stats
export const adminGetProductStats = () =>
  apiCall("/admin/products/stats", { method: "GET" });

export const adminGetAllProducts = (filters = {}) => {
  const params = new URLSearchParams(filters).toString();
  return apiCall(`/admin/products${params ? `?${params}` : ""}`, {
    method: "GET",
  });
};

// GET /api/admin/products/:id
export const adminGetProductById = (productId) =>
  apiCall(`/admin/products/${productId}`, { method: "GET" });

// PATCH /api/admin/products/:id/approve
export const adminApproveProduct = (productId) =>
  apiCall(`/admin/products/${productId}/approve`, { method: "PATCH" });

// PATCH /api/admin/products/:id/reject
export const adminRejectProduct = (productId, reason = "") =>
  apiCall(`/admin/products/${productId}/reject`, {
    method: "PATCH",
    body: JSON.stringify({ reason }),
  });

// DELETE /api/admin/products/:id
export const adminDeleteProduct = (productId) =>
  apiCall(`/admin/products/${productId}`, { method: "DELETE" });

// PATCH /api/admin/products/:id/visibility
export const adminToggleProductVisibility = (productId, is_active) =>
  apiCall(`/admin/products/${productId}/visibility`, {
    method: "PATCH",
    body: is_active !== undefined ? JSON.stringify({ is_active }) : undefined,
  });

// GET /api/admin/jewellers/:jeweller_id/products

export const adminGetProductsByJeweller = (jewellerId) =>
  apiCall(`/admin/jewellers/${jewellerId}/products`, { method: "GET" });

export const saveDocumentUrls = (documents) =>
  apiCall("/documents/my/save", {
    method: "POST",
    body: JSON.stringify({ documents }),
  });

export const getMyDocuments = () => apiCall("/documents/my", { method: "GET" });

export const getJewellerDocuments = (jewellerId) =>
  apiCall(`/documents/${jewellerId}`, { method: "GET" });

export const addDocumentFeedback = (jewellerId, documentKey, feedback) =>
  apiCall(`/documents/${jewellerId}/feedback`, {
    method: "POST",
    body: JSON.stringify({ document_key: documentKey, feedback }),
  });

export const getAdminActionLogs = (jewellerId) =>
  apiCall(`/documents/${jewellerId}/logs`, { method: "GET" });

export const getServerInfo = () => fetch("/").then((res) => res.json());

export const adminGetAllOrders = (filters = {}) => {
  const params = new URLSearchParams(filters).toString();
  return apiCall(`/admin/orders${params ? `?${params}` : ""}`, {
    method: "GET",
  });
};

export const adminGetOrderById = (orderId) =>
  apiCall(`/admin/orders/${orderId}`, { method: "GET" });

export const adminGetOrderStats = () =>
  apiCall("/admin/orders/stats", { method: "GET" });

export const adminUpdateOrderStatus = (orderId, status, note = "") =>
  apiCall(`/admin/orders/${orderId}/status`, {
    method: "PATCH",
    body: JSON.stringify({ status, note }),
  });

export const adminDeleteOrder = (orderId) =>
  apiCall(`/admin/orders/${orderId}`, { method: "DELETE" });
