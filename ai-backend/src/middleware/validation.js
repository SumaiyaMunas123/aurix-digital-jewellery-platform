/**
 * Rate limiting and request validation middleware
 * Uses response.js and validators.js for consistent response formatting and validation logic
 */

import { sendError } from '../utils/response.js';
import {
  validatePrompt as validatePromptUtil,
  validateGenerationParams as validateGenerationParamsUtil,
  validateFile,
} from '../utils/validators.js';

const requestCounts = new Map();
const RATE_LIMIT = 10; // requests per minute per user
const RATE_WINDOW = 60 * 1000; // 1 minute

/**
 * Rate limiting middleware
 * Enforces 10 requests per minute per user
 * Returns 429 with retryAfter metadata on limit exceeded
 */
export const rateLimitAI = (req, res, next) => {
  const userId = req.user?.id || req.ip;
  const now = Date.now();

  if (!requestCounts.has(userId)) {
    requestCounts.set(userId, []);
  }

  const userRequests = requestCounts.get(userId);
  const recentRequests = userRequests.filter(time => now - time < RATE_WINDOW);

  if (recentRequests.length >= RATE_LIMIT) {
    console.warn(`⚠️ Rate limit exceeded for user: ${userId}`);
    const retryAfterSeconds = Math.ceil((recentRequests[0] + RATE_WINDOW - now) / 1000);
    return sendError(res, 'Rate limit exceeded. Too many requests.', 429, {
      retryAfter: retryAfterSeconds,
      retryGuidance: `Please wait ${retryAfterSeconds} seconds before retrying.`,
    });
  }

  recentRequests.push(now);
  requestCounts.set(userId, recentRequests);

  next();
};

/**
 * Prompt validation middleware
 * Validates prompt length (1-500 chars) and content (no XSS/script injection)
 * Mode 0 (text-to-image) requires prompt; Mode 1 (sketch-to-image) does not
 */
export const validatePrompt = (req, res, next) => {
  const { mode = 0 } = req.body;
  const modeInt = parseInt(mode);

  // Text-to-image mode requires prompt
  if (modeInt === 0) {
    const result = validatePromptUtil(req.body.prompt);
    if (!result.valid) {
      return sendError(res, result.error, 400);
    }
  }

  next();
};

/**
 * Generation parameters validation middleware
 * Validates mode (0 or 1), karat, material, style against allowed values
 */
export const validateGenerationParams = (req, res, next) => {
  const result = validateGenerationParamsUtil(req.body);
  if (!result.valid) {
    return sendError(res, result.error, 400);
  }

  next();
};

/**
 * File upload validation middleware
 * Validates file size (max 50MB), MIME type (image only)
 */
export const validateFileUpload = (req, res, next) => {
  if (!req.file) {
    return sendError(res, 'No file provided', 400);
  }

  const result = validateFile(req.file);
  if (!result.valid) {
    return sendError(res, result.error, 400);
  }

  next();
};

/**
 * Timeout handler middleware
 * Aborts request after specified timeout with 503 Service Unavailable
 * Includes retryGuidance for client retry logic
 */
export const timeoutHandler = (timeout = 120000) => {
  return (req, res, next) => {
    const timeoutId = setTimeout(() => {
      if (!res.headersSent) {
        sendError(res, 'Request timeout. Generation took too long.', 503, {
          retryGuidance: 'The AI generation request exceeded the 120-second timeout. Please try with a simpler prompt or lower image quality parameters.',
          timeoutSeconds: 120,
        });
      }
    }, timeout);

    res.on('finish', () => clearTimeout(timeoutId));
    next();
  };
};
