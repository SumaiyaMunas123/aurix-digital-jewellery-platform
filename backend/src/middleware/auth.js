import { verifyAuthToken } from '../utils/jwt.js';
import { sendAuthError } from '../utils/responseFormatter.js';

const getBearerToken = (authorizationHeader) => {
  if (!authorizationHeader || typeof authorizationHeader !== 'string') {
    return null;
  }

  const [scheme, token] = authorizationHeader.split(' ');
  if (scheme !== 'Bearer' || !token) {
    return null;
  }

  return token;
};

export const requireAuth = (req, res, next) => {
  try {
    const token = getBearerToken(req.headers.authorization);

    if (!token) {
      return sendAuthError(res, 'Missing or invalid authorization header', 401);
    }

    const decoded = verifyAuthToken(token);
    req.user = {
      id: decoded.sub,
      role: decoded.role,
      email: decoded.email,
      name: decoded.name,
    };

    return next();
  } catch (error) {
    return sendAuthError(res, 'Invalid or expired token', 401);
  }
};

export const requireRole = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return sendAuthError(res, 'Authentication required', 401);
    }

    if (!roles.includes(req.user.role)) {
      return sendAuthError(res, 'You do not have permission to perform this action', 403);
    }

    return next();
  };
};

export const requireAdmin = (req, res, next) => {
  if (!req.user) {
    return sendAuthError(res, 'Authentication required', 401);
  }

  if (req.user.role !== 'admin') {
    return sendAuthError(res, 'Admin access only', 403);
  }

  return next();
};
