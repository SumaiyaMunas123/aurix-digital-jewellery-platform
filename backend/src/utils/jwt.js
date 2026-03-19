import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'dev-secret-change-me';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

export const signAuthToken = (user) => {
  const payload = {
    sub: user.id,
    role: user.role,
    email: user.email,
    name: user.name,
  };

  return jwt.sign(payload, JWT_SECRET, {
    expiresIn: JWT_EXPIRES_IN,
  });
};

export const verifyAuthToken = (token) => {
  return jwt.verify(token, JWT_SECRET);
};