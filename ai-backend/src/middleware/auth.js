/**
 * Authentication middleware for AI routes
 * Validates user identity via JWT or anonymous token
 */

export const validateUserAuth = (req, res, next) => {
  try {
    // For now, allow requests with optional user_id in body
    // In production, validate JWT from Authorization header
    const { user_id, user_type } = req.body;

    // Optional: If JWT is provided, validate it
    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      // TODO: Verify JWT signature here
      // For now, just allow it through
    }

    // Allow anonymous requests (user_id optional)
    req.user = {
      id: user_id || null,
      type: user_type || 'customer',
      isAuthenticated: !!user_id,
    };

    next();
  } catch (error) {
    console.error('❌ Auth error:', error.message);
    return res.status(401).json({ success: false, error: 'Authentication failed' });
  }
};

export const requireAuth = (req, res, next) => {
  // If you want to enforce authentication later, uncomment:
  // if (!req.user?.isAuthenticated) {
  //   return res.status(401).json({ success: false, error: 'User authentication required' });
  // }
  next();
};
