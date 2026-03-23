import test from 'node:test';
import assert from 'node:assert/strict';

import {
  validatePrompt,
  validateFile,
  validateGenerationParams,
  validateUserScoping,
  validateBase64Image,
} from '../src/utils/validators.js';

test('validatePrompt accepts good prompt and rejects invalid prompt', () => {
  assert.equal(validatePrompt('A luxury jewelry photoshoot with soft lighting').valid, true);
  assert.equal(validatePrompt('').valid, false);
  assert.equal(validatePrompt('x'.repeat(2001)).valid, false);
});

test('validateGenerationParams validates dimensions and counts', () => {
  assert.equal(validateGenerationParams({ mode: 0, karat: '18K', material: 'gold' }).valid, true);
  assert.equal(validateGenerationParams({ mode: 3 }).valid, false);
  assert.equal(validateGenerationParams({ style: 'invalid-style' }).valid, false);
});

test('validateImageFile checks mimetype and size', () => {
  const validFile = { mimetype: 'image/png', size: 1000 };
  const invalidType = { mimetype: 'application/pdf', size: 1000 };
  const invalidSize = { mimetype: 'image/jpeg', size: 50 * 1024 * 1024 + 1 };

  assert.equal(validateFile(validFile).valid, true);
  assert.equal(validateFile(invalidType).valid, false);
  assert.equal(validateFile(invalidSize).valid, false);
});

test('validateUserScoping and base64 validation behavior', () => {
  assert.equal(validateUserScoping('u1', 'u1').valid, true);
  assert.equal(validateUserScoping('u1', 'u2').valid, false);

  const validBase64 = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAAB';
  const invalidBase64 = 'not_base64';

  assert.equal(validateBase64Image(validBase64).valid, true);
  assert.equal(validateBase64Image(invalidBase64).valid, false);
});
