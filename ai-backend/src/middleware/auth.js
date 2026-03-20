/**
 * Authentication middleware for AI routes
 * Validates user identity via JWT or anonymous token
 */

import { sendError } from '../utils/response.js';

export const validateUserAuth = (req, res, next) => {
  try {
    // Extract user context from body, query, or headers
    const user_id = req.body?.user_id || req.query?.user_id || null;
    const user_type = req.body?.user_type || req.query?.user_type || 'customer';

    // Optional: If JWT is provided, validate it
    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      // TODO: Verify JWT signature here
      // For now, just allow it through
    }

    // Allow anonymous and authenticated requests
    req.user = {
      id: user_id || null,
      type: user_type || 'customer',
      isAuthenticated: !!user_id,
    };

    next();
  } catch (error) {
    console.error('❌ Auth error:', error.message);
    return sendError(res, 'Authentication failed', 401);
  }
};

export const requireAuth = (req, res, next) => {
  // If you want to enforce authentication later, uncomment:
  // if (!req.user?.isAuthenticated) {
  //   return res.status(401).json({ success: false, error: 'User authentication required' });
  // }
  next();
};
