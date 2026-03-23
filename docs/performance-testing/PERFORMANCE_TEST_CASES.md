# 2.6 Performance Testing - Test Cases

## Scope
This document defines MVP-level performance checks for Aurix using Postman.

## Environment
- Backend base URL: `http://localhost:5000`
- AI backend base URL: `http://localhost:7000`
- Gold-rate base URL: `http://localhost:6000`
- Network: local development
- Load profile: normal usage (single user / low concurrency)

## Acceptance Targets (MVP)
- Authentication endpoints: < 1200 ms
- Product listing endpoints: < 1000 ms
- Chat endpoints: < 1200 ms
- Admin verification endpoints: < 1500 ms
- Error rate during normal usage: 0%

## Test Cases

| ID | Module | Endpoint | Method | Scenario | Expected Result |
|---|---|---|---|---|---|
| PERF-001 | User Authentication | `/auth/login` | POST | Login with valid credentials | HTTP 200 and response time < 1200 ms |
| PERF-002 | Jewellery Listing | `/products` | GET | Load product list for customer home | HTTP 200 and response time < 1000 ms |
| PERF-003 | Chat Functionality | `/chat/threads/:user_id` | GET | Load chat threads for logged-in user | HTTP 200 and response time < 1200 ms |
| PERF-004 | Jeweller Check Requests | `/admin/jewellers/pending` | GET | Admin loads pending jeweller verifications | HTTP 200 and response time < 1500 ms |

## Run Guidance
1. Use Postman Collection Runner.
2. Run each case for at least 20 iterations.
3. Record average response time, min/max, and failure count.
4. Capture screenshots of Postman test results and response-time chart.

## Result Summary Template
- PERF-001: Pass/Fail, Avg: ___ ms
- PERF-002: Pass/Fail, Avg: ___ ms
- PERF-003: Pass/Fail, Avg: ___ ms
- PERF-004: Pass/Fail, Avg: ___ ms

## Note
Current results represent MVP behavior under normal usage. Additional high-concurrency and soak testing are recommended in later phases for scalability validation.
