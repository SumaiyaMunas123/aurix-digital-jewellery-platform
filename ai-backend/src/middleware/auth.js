/**
 * Authentication middleware for AI routes
 * Validates JWT tokens from main backend
 */

import jwt from 'jsonwebtoken';
import { sendError } from '../utils/response.js';

const JWT_SECRET = process.env.JWT_SECRET || 'dev-secret-change-me';

export const validateUserAuth = (req, res, next) => {
  try {
    // Extract user context from body, query, or headers
    const user_type = req.body?.user_type || req.query?.user_type || 'customer';

    // Optional: If JWT is provided, validate it
    const authHeader = req.headers.authorization;

    // Check for JWT in Authorization header
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      try {
        const decoded = jwt.verify(token, JWT_SECRET);
        req.user = {
          id: decoded.sub,
          email: decoded.email,
          name: decoded.name,
          role: decoded.role,
          isAuthenticated: true,
        };
        return next();
      } catch (tokenError) {
        console.error('❌ Token verification failed:', tokenError.message);
        return res.status(401).json({
          success: false,
          message: 'Invalid or expired token',
          error: tokenError.message,
        });
      }
    }

    // Allow anonymous requests with optional user_id (for development)
    const { user_id } = req.body;
    // Allow anonymous and authenticated requests
    req.user = {
      id: user_id || null,
      isAuthenticated: !!user_id,
    };

    next();
  } catch (error) {
    console.error('❌ Auth middleware error:', error.message);
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
  next();
};
