# Postman Screenshot Checklist (Section 2.6)

Capture these screenshots for report proof:

1. Collection Runner setup
- Show selected collection, environment, and iteration count (e.g., 20).

2. PERF-001 Authentication
- Request: `POST /auth/login`
- Show test tab where status and response-time assertion passed.

3. PERF-002 Jewellery Listing
- Request: `GET /products`
- Show response and passed response-time assertion.

4. PERF-003 Chat
- Request: `GET /chat/threads/:user_id`
- Show Authorization header and passed tests.

5. PERF-004 Jeweller Check Requests
- Request: `GET /admin/jewellers/pending`
- Show admin token usage and passed tests.

6. Runner Summary
- Show total runs, pass count, fail count, and average timing from runner output.

## Suggested Caption Format
- "Figure X: PERF-00Y [Scenario] performance validation in Postman (status and response-time assertions passed)."
