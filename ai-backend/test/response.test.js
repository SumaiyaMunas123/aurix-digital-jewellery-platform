import test from 'node:test';
import assert from 'node:assert/strict';

import {
  createSuccessResponse,
  createErrorResponse,
} from '../src/utils/response.js';

test('createSuccessResponse returns standard success shape', () => {
  const data = { id: 'abc', status: 'ok' };
  const result = createSuccessResponse(data, { message: 'Generated' });

  assert.equal(result.success, true);
  assert.equal(result.message, 'Generated');
  assert.deepEqual(result.data, data);
  assert.ok(typeof result.timestamp === 'string');
});

test('createErrorResponse returns standard error shape', () => {
  const result = createErrorResponse('Failed', 400);

  assert.equal(result.success, false);
  assert.equal(result.error, 'Failed');
  assert.equal(result.data, null);
  assert.ok(typeof result.timestamp === 'string');
});

test('createErrorResponse includes retry metadata for specific status codes', () => {
  const result = createErrorResponse('Rate limited', 429, { retryAfter: 60 });

  assert.equal(result.success, false);
  assert.equal(result.error, 'Rate limited');
  assert.equal(result.retryAfter, 60);
});
