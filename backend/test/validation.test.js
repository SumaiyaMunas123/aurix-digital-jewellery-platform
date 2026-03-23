import test from 'node:test';
import assert from 'node:assert/strict';

import {
  validateRequiredFields,
  validateEmail,
  validatePassword,
  validatePhoneNumber,
  validatePositiveNumber,
  sanitizeEmail,
  sanitizePhone,
} from '../src/utils/validation.js';

test('validateRequiredFields returns missing fields', () => {
  const missing = validateRequiredFields(
    { name: 'Aurix', email: '   ', phone: null },
    ['name', 'email', 'phone'],
  );

  assert.deepEqual(missing, ['email', 'phone']);
});

test('validateRequiredFields returns null when all fields present', () => {
  const missing = validateRequiredFields(
    { name: 'Aurix', email: 'hello@aurix.com', phone: '0771234567' },
    ['name', 'email', 'phone'],
  );

  assert.equal(missing, null);
});

test('email/password/phone validators handle valid and invalid values', () => {
  assert.equal(validateEmail('user@aurix.com'), true);
  assert.equal(validateEmail('user@aurix'), false);

  assert.equal(validatePassword('Abcd1234'), true);
  assert.equal(validatePassword('abcd1234'), false);

  assert.equal(validatePhoneNumber('+94 77 123 4567'), true);
  assert.equal(validatePhoneNumber('123'), false);
});

test('sanitize helpers normalize values', () => {
  assert.equal(sanitizeEmail('  USER@Aurix.Com '), 'user@aurix.com');
  assert.equal(sanitizePhone(' +94 (77) 123-4567 '), '94771234567');
});

test('validatePositiveNumber checks numeric positivity', () => {
  assert.equal(validatePositiveNumber('1200.50'), true);
  assert.equal(validatePositiveNumber('-5'), false);
  assert.equal(validatePositiveNumber('abc'), false);
});
