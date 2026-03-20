/**
 * Centralized API Response Formatter
 * Ensures consistent response structure across all endpoints
 */

export const sendSuccess = (res, data = null, message = 'Success', statusCode = 200) => {
  return res.status(statusCode).json({
    success: true,
    message,
    ...(data && { data }),
    timestamp: new Date().toISOString(),
  });
};

export const sendError = (res, message = 'Server error', statusCode = 500, error = null) => {
  const response = {
    success: false,
    message,
    timestamp: new Date().toISOString(),
  };

  if (process.env.NODE_ENV === 'development' && error) {
    response.error = error.message || error;
  }

  return res.status(statusCode).json(response);
};

export const sendValidationError = (res, message = 'Validation failed', details = null) => {
  const response = {
    success: false,
    message,
    timestamp: new Date().toISOString(),
  };

  if (details) {
    response.details = details;
  }

  return res.status(400).json(response);
};

export const sendAuthError = (res, message = 'Unauthorized', statusCode = 401) => {
  return res.status(statusCode).json({
    success: false,
    message,
    timestamp: new Date().toISOString(),
  });
};
