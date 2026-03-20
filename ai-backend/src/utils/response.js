/**
 * Standardized response formatter for all AI Backend endpoints
 * Ensures consistent JSON schema across all routes
 */

export const createSuccessResponse = (data, options = {}) => {
  return {
    success: true,
    data: data || null,
    message: options.message || null,
    timestamp: new Date().toISOString(),
  };
};

export const createErrorResponse = (error, statusCode = 500, options = {}) => {
  const response = {
    success: false,
    data: null,
    error: typeof error === 'string' ? error : error.message,
    timestamp: new Date().toISOString(),
  };

  // Add retry metadata for rate limit and timeout errors
  if (statusCode === 429 && options.retryAfter) {
    response.retryAfter = options.retryAfter;
  }

  if (statusCode === 503 && options.retryGuidance) {
    response.retryGuidance = options.retryGuidance;
  }

  return response;
};

export const sendSuccess = (res, data, options = {}) => {
  const statusCode = options.statusCode || 200;
  return res.status(statusCode).json(createSuccessResponse(data, options));
};

export const sendError = (res, error, statusCode = 500, options = {}) => {
  return res.status(statusCode).json(createErrorResponse(error, statusCode, options));
};
