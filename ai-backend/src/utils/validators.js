/**
 * Enhanced validation utilities for AI Backend
 * Validates prompts, params, file uploads with comprehensive checks
 */

const PROMPT_CONSTRAINTS = {
  MIN_LENGTH: 1,
  MAX_LENGTH: 500,
};

const DANGEROUS_PATTERNS = [
  /script/i,
  /eval/i,
  /<script/i,
  /<!--/,
  /onclick/i,
  /onerror/i,
  /javascript:/i,
  /on\w+\s*=/i, // onload=, onmouseover=, etc
];

const FILE_CONSTRAINTS = {
  MAX_SIZE: 50 * 1024 * 1024, // 50MB
  ALLOWED_MIMES: ['image/jpeg', 'image/png', 'image/webp'],
  ALLOWED_EXTENSIONS: ['.jpg', '.jpeg', '.png', '.webp'],
};

const STYLE_CONSTRAINTS = {
  VALID_KARAT: ['8K', '10K', '14K', '18K', '22K', '24K'],
  VALID_MATERIALS: ['gold', 'silver', 'platinum', 'rose-gold', 'white-gold'],
  VALID_STYLES: ['elegant', 'classic', 'modern', 'minimalist', 'ornate', 'art-deco'],
};

/**
 * Validate prompt length and content
 */
export const validatePrompt = (prompt) => {
  if (!prompt || typeof prompt !== 'string') {
    return { valid: false, error: 'Prompt must be a non-empty string' };
  }

  const trimmed = prompt.trim();

  if (trimmed.length < PROMPT_CONSTRAINTS.MIN_LENGTH) {
    return { valid: false, error: 'Prompt cannot be empty' };
  }

  if (trimmed.length > PROMPT_CONSTRAINTS.MAX_LENGTH) {
    return {
      valid: false,
      error: `Prompt exceeds maximum length of ${PROMPT_CONSTRAINTS.MAX_LENGTH} characters. Current: ${trimmed.length}`,
    };
  }

  // Check for dangerous patterns
  for (const pattern of DANGEROUS_PATTERNS) {
    if (pattern.test(trimmed)) {
      return { valid: false, error: 'Prompt contains disallowed content (script/injection attempt)' };
    }
  }

  return { valid: true };
};

/**
 * Validate generation parameters (mode, style params, etc)
 */
export const validateGenerationParams = (params) => {
  const { mode, karat, material, style } = params;

  // Validate mode
  if (mode !== undefined) {
    const modeInt = parseInt(mode);
    if (![0, 1].includes(modeInt)) {
      return { valid: false, error: 'Invalid mode. Use 0 for text-to-image or 1 for sketch-to-image' };
    }
  }

  // Validate karat if provided
  if (karat && !STYLE_CONSTRAINTS.VALID_KARAT.includes(String(karat).toUpperCase())) {
    return {
      valid: false,
      error: `Invalid karat. Must be one of: ${STYLE_CONSTRAINTS.VALID_KARAT.join(', ')}`,
    };
  }

  // Validate material if provided
  if (material && !STYLE_CONSTRAINTS.VALID_MATERIALS.includes(String(material).toLowerCase())) {
    return {
      valid: false,
      error: `Invalid material. Must be one of: ${STYLE_CONSTRAINTS.VALID_MATERIALS.join(', ')}`,
    };
  }

  // Validate style if provided
  if (style && !STYLE_CONSTRAINTS.VALID_STYLES.includes(String(style).toLowerCase())) {
    return {
      valid: false,
      error: `Invalid style. Must be one of: ${STYLE_CONSTRAINTS.VALID_STYLES.join(', ')}`,
    };
  }

  return { valid: true };
};

/**
 * Validate uploaded file (size, type, extension)
 */
export const validateFile = (file) => {
  if (!file) {
    return { valid: false, error: 'No file provided' };
  }

  // Check file size
  if (file.size > FILE_CONSTRAINTS.MAX_SIZE) {
    const sizeMB = (file.size / (1024 * 1024)).toFixed(2);
    const maxMB = (FILE_CONSTRAINTS.MAX_SIZE / (1024 * 1024)).toFixed(0);
    return {
      valid: false,
      error: `File size ${sizeMB}MB exceeds maximum of ${maxMB}MB`,
    };
  }

  // Check MIME type
  if (!FILE_CONSTRAINTS.ALLOWED_MIMES.includes(file.mimetype)) {
    return {
      valid: false,
      error: `Invalid file type: ${file.mimetype}. Allowed: ${FILE_CONSTRAINTS.ALLOWED_MIMES.join(', ')}`,
    };
  }

  return { valid: true };
};

/**
 * Validate base64 image string
 */
export const validateBase64Image = (base64String) => {
  if (!base64String || typeof base64String !== 'string') {
    return { valid: false, error: 'Base64 string is required and must be a string' };
  }

  // Basic base64 validation
  try {
    const base64Regex = /^data:image\/(png|jpg|jpeg|webp);base64,(.+)$/;
    const matches = base64String.match(base64Regex);

    if (!matches) {
      return { valid: false, error: 'Invalid base64 format. Expected: data:image/[type];base64,[data]' };
    }

    return { valid: true };
  } catch (error) {
    return { valid: false, error: 'Failed to validate base64 image' };
  }
};

/**
 * Validate user ID for scoping
 */
export const validateUserScoping = (userId, requestUserId) => {
  if (!userId) {
    return { valid: false, error: 'User ID is required' };
  }

  // If both are provided, they must match (unless admin override)
  if (requestUserId && userId !== requestUserId) {
    return { valid: false, error: 'User ID mismatch. Cannot access designs for other users.' };
  }

  return { valid: true };
};
