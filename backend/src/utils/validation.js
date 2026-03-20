/**
 * Centralized Request Validation Utilities
 * Provides reusable validation functions
 */

export const validateRequiredFields = (obj, requiredFields) => {
  const missing = [];
  
  for (const field of requiredFields) {
    const value = obj[field];
    if (value === undefined || value === null || (typeof value === 'string' && !value.trim())) {
      missing.push(field);
    }
  }
  
  return missing.length > 0 ? missing : null;
};

export const validateEmail = (email) => {
  const pattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return pattern.test(email);
};

export const validatePassword = (password) => {
  // At least 8 chars, 1 uppercase, 1 lowercase, 1 number
  const pattern = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/;
  return pattern.test(password);
};

export const validatePhoneNumber = (phone) => {
  const digits = phone.replace(/\D/g, '');
  return digits.length >= 9 && digits.length <= 15;
};

export const validateNonEmptyString = (value, minLength = 1, maxLength = null) => {
  if (typeof value !== 'string' || !value.trim()) {
    return false;
  }
  const trimmed = value.trim();
  if (trimmed.length < minLength) return false;
  if (maxLength && trimmed.length > maxLength) return false;
  return true;
};

export const validatePositiveNumber = (value) => {
  const num = parseFloat(value);
  return !isNaN(num) && num > 0;
};

export const validateEnumValue = (value, allowedValues) => {
  return allowedValues.includes(value);
};

export const sanitizeString = (value) => {
  if (typeof value !== 'string') return '';
  return value.trim();
};

export const sanitizeEmail = (email) => {
  return sanitizeString(email).toLowerCase();
};

export const sanitizePhone = (phone) => {
  return sanitizeString(phone).replace(/\D/g, '');
};
