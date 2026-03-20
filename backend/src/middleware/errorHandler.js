/**
 * Centralized Error Handling Middleware
 * Catches unhandled errors and responds with consistent format
 */

import { sendError } from '../utils/responseFormatter.js';

export const errorHandler = (err, req, res, next) => {
  console.error(`\n❌ [${new Date().toLocaleTimeString()}] ERROR on ${req.method} ${req.path}`);
  console.error('Error:', err.message);
  
  if (process.env.NODE_ENV === 'development') {
    console.error('Stack:', err.stack);
  }

  // Supabase errors
  if (err.code === 'PGRST116') {
    return sendError(res, 'Resource not found', 404);
  }

  if (err.code === '42P01') {
    return sendError(res, 'Database table not found', 500);
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    return sendError(res, 'Invalid token', 401);
  }

  if (err.name === 'TokenExpiredError') {
    return sendError(res, 'Token expired', 401);
  }

  // Validation errors
  if (err.statusCode === 400) {
    return sendError(res, err.message || 'Validation error', 400);
  }

  // Default error
  return sendError(res, 'Server error', 500, err);
};

export const asyncHandler = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

export const notFoundHandler = (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found',
    path: req.path,
    method: req.method,
    timestamp: new Date().toISOString(),
  });
};
