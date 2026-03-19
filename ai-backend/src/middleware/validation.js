/**
 * Rate limiting and request validation middleware
 */

const requestCounts = new Map();
const RATE_LIMIT = 10; // requests per minute per user
const RATE_WINDOW = 60 * 1000; // 1 minute

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
    return res.status(429).json({
      success: false,
      error: 'Too many requests. Please try again later.',
      retryAfter: Math.ceil((recentRequests[0] + RATE_WINDOW - now) / 1000),
    });
  }

  recentRequests.push(now);
  requestCounts.set(userId, recentRequests);

  next();
};

export const validatePrompt = (req, res, next) => {
  const { prompt, mode = 0 } = req.body;
  const modeInt = parseInt(mode);

  // Text-to-image mode
  if (modeInt === 0) {
    if (!prompt || typeof prompt !== 'string') {
      return res.status(400).json({
        success: false,
        error: 'prompt must be a string',
      });
    }

    const trimmed = prompt.trim();
    const MAX_LENGTH = 500;

    if (trimmed.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'prompt cannot be empty',
      });
    }

    if (trimmed.length > MAX_LENGTH) {
      return res.status(400).json({
        success: false,
        error: `prompt exceeds maximum length of ${MAX_LENGTH} characters`,
      });
    }

    // Disallow potentially harmful prompts (basic filter)
    const dangerousPatterns = ['script', 'eval', '<script', '<!--', 'onclick'];
    const lowerPrompt = trimmed.toLowerCase();
    if (dangerousPatterns.some(pattern => lowerPrompt.includes(pattern))) {
      return res.status(400).json({
        success: false,
        error: 'prompt contains disallowed content',
      });
    }
  }

  next();
};

export const validateGenerationParams = (req, res, next) => {
  const { mode = 0, budget, weight, karat } = req.body;

  // Validate mode
  const modeInt = parseInt(mode);
  if (![0, 1].includes(modeInt)) {
    return res.status(400).json({
      success: false,
      error: 'Invalid mode. Use 0 for text-to-image or 1 for sketch-to-image',
    });
  }

  // Optional: Validate karat (if provided)
  if (karat) {
    const validKarats = ['8K', '10K', '14K', '18K', '22K', '24K'];
    if (!validKarats.includes(String(karat).toUpperCase())) {
      return res.status(400).json({
        success: false,
        error: `Invalid karat. Must be one of: ${validKarats.join(', ')}`,
      });
    }
  }

  next();
};

export const timeoutHandler = (timeout = 120000) => {
  return (req, res, next) => {
    const timeoutId = setTimeout(() => {
      if (!res.headersSent) {
        res.status(503).json({
          success: false,
          error: 'Request timeout. Please try again.',
        });
      }
    }, timeout);

    res.on('finish', () => clearTimeout(timeoutId));
    next();
  };
};
