/**
 * Authentication middleware for AI routes
 * Validates JWT tokens from main backend
 */

import jwt from 'jsonwebtoken';
const JWT_SECRET = process.env.JWT_SECRET || 'dev-secret-change-me';

export const validateUserAuth = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    // If a bearer token is present, verify and use authenticated context.
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);

      try {
        const decoded = jwt.verify(token, JWT_SECRET);
        req.user = {
          id: decoded.sub || decoded.id || null,
          email: decoded.email || null,
          name: decoded.name || null,
          role: decoded.role || null,
          isAuthenticated: true,
        };
        return next();
      } catch (tokenError) {
        return res.status(401).json({
          success: false,
          message: 'Invalid or expired token',
          error: tokenError.message,
        });
      }
    }

    // Allow anonymous requests with optional user context.
    const userId = req.body?.user_id || req.query?.user_id || null;
    req.user = {
      id: userId,
      role: req.body?.user_type || req.query?.user_type || 'customer',
      isAuthenticated: false,
    };

    return next();
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Authentication failed',
      error: error.message,
    });
  }
};

export const requireAuth = (req, res, next) => {
  if (!req.user?.isAuthenticated) {
    return res.status(401).json({
      success: false,
      message: 'Authentication required',
    });
  }

  return next();
};
