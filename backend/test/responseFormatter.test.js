import test from 'node:test';
import assert from 'node:assert/strict';

import {
  sendSuccess,
  sendError,
  sendValidationError,
  sendAuthError,
} from '../src/utils/responseFormatter.js';

const createMockRes = () => ({
  statusCode: null,
  payload: null,
  status(code) {
    this.statusCode = code;
    return this;
  },
  json(body) {
    this.payload = body;
    return this;
  },
});

test('sendSuccess sets success payload and status', () => {
  const res = createMockRes();
  sendSuccess(res, { ok: true }, 'Done', 201);

  assert.equal(res.statusCode, 201);
  assert.equal(res.payload.success, true);
  assert.equal(res.payload.message, 'Done');
  assert.deepEqual(res.payload.data, { ok: true });
  assert.ok(typeof res.payload.timestamp === 'string');
});

test('sendError sets failure payload and status', () => {
  const res = createMockRes();
  sendError(res, 'Nope', 500);

  assert.equal(res.statusCode, 500);
  assert.equal(res.payload.success, false);
  assert.equal(res.payload.message, 'Nope');
});

test('sendValidationError and sendAuthError return expected status codes', () => {
  const resValidation = createMockRes();
  sendValidationError(resValidation, 'Bad input', { field: 'email' });
  assert.equal(resValidation.statusCode, 400);
  assert.equal(resValidation.payload.success, false);
  assert.deepEqual(resValidation.payload.details, { field: 'email' });

  const resAuth = createMockRes();
  sendAuthError(resAuth, 'Unauthorized');
  assert.equal(resAuth.statusCode, 401);
  assert.equal(resAuth.payload.success, false);
});
