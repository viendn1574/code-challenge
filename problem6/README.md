# Specification for Scoreboard API Module

## Overview

This document specifies the **Scoreboard API Module** — a backend service responsible for securely
processing score updates and delivering real-time scoreboard data to connected clients.

## Table of Contents

1. Architecture Overview
2. API Reference
3. Authentication & Security
4. Real-time Delivery
5. Data Model
6. Sequence Diagram
7. Technical Constraints & Notes

## Architecture Overview

Client (Browser)
    |
    |-- HTTPS POST /api/scores/update   // score increment request
    │
    |-- WSS  /ws/scoreboard             // receive live top-10 updates
         │
   +-----------------------------+
   │     API Gateway / LB        │
   +-----------------------------+
                │
   +-----------------------------+
   │     Application Server      │
   │  +------------------------+ │
   │  │  Auth Middleware       │ │  // verify JWT + action token
   │  |------------------------| │
   │  │  Score Controller      │ │  // validate, increment, broadcast
   │  |------------------------| │
   │  │  WebSocket Manager     │ │  // manage subscriber connections
   │  +------------------------+ │
   +-----------------------------+
                │
   +-----------------------------+
   │         Database            │
   │   users, scores, actions    │
   +-----------------------------+

## API Reference

### POST `/api/scores/update`
Increments the user's score

**Request Headers:**

| Header          | Required | Description                               |
|-----------------|----------|-------------------------------------------|
| `Authorization` | Yes      | `Bearer <jwt_token>`                      |
| `Content-Type`  | Yes      | `application/json`                        |

**Request Body:**

| Field           | Type    | Required | Description                               |
|-----------------|---------|----------|-------------------------------------------|
| `action_token`  | String  | Yes      | `Bearer <jwt_token>`                      |
| `delta`         | Integer | Yes      | `The score modification value`            |

**Success Response — 200 OK:**
```json
{
  "success": true,
  "data": {
    "user_id": "usr_abc123",
    "old_score": 30,
    "new_score": 40,
    "rank": 7
  }
}
```
**Failed Response:**
```json
{
  "success": false,
  "error": {
    "code": "MISSING_TOKEN",
    "message": "Action token not provided ."
  }
}
```

**Error Responses:**

| Status | Code               | Reason                                      |
|--------+--------------------+---------------------------------------------|
| 400    | MISSING_TOKEN      | action_token not provided                   |
| 400    | INVALID_DELTA      | delta is missing, zero, or negative         |
| 401    | UNAUTHORIZED       | JWT missing, expired, or invalid            |
| 403    | TOKEN_ALREADY_USED | action_token has already been consumed      |
| 403    | TOKEN_INVALID      | action_token signature invalid or not found |
| 429    | RATE_LIMITED       | Too many requests from this user            |

### GET `/api/scores/top`

Returns the top-n users by score (HTTP, non-live).

**Authentication:** Optional (public endpoint).

**Query Parameters:**

| Param           | Type    | Required | Default | Description                              |
|-----------------|---------|----------|---------|------------------------------------------|
| `n`             | Integer | No       | 10      | `application/json`                       |

**Example:** GET /api/scores/top?n=20

**Response - `200 OK`:**

```json
{
  "success": true,
  "data": {
    "updated_at": "2024-03-15T10:30:00Z",
    "scores": [
      { "rank": 1, "user_id": "usr_xyz", "username": "vien", "score": 980 },
      { "rank": 2, "user_id": "usr_abc", "username": "aaa",   "score": 875 },
      ....
    ]
  }
}
```
**Failed Response:**
```json
{
  "success": false,
  "error": {
    "code": "INVALID_N",
    "message": "n is not a positive integer or exceeds 100 ."
  }
}
```
**Error Responses:**

| Status | Code               | Reason                                      |
|--------+--------------------+---------------------------------------------|
| 400    | INVALID_N          | n is not a positive integer or exceeds 100  |

### WebSocket `/ws/scoreboard`
Live scoreboard feed. The server pushes an updated top-10 list whenever any score changes.
**Connection:**
```
WSS /ws/scoreboard
```
No authentication required to subscribe (read-only public feed).

**Server -> Client message:**

```json
{
  "event": "scoreboard_update",
  "data": {
    "updated_at": "2024-03-15T10:30:01Z",
    "updated_at": "2024-03-15T10:30:00Z",
    "scores": [
      { "rank": 1, "user_id": "usr_xyz", "username": "vien", "score": 980 },
      { "rank": 2, "user_id": "usr_abc", "username": "aaa",   "score": 875 },
      .....
    ]
  }
}
```

The server broadcasts this message to **all connected clients** after every successful score update.

## Authentication & Security

### 1. JWT — User Identity

All score update requests require a valid JWT in the `Authorization` header:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

The JWT must contain:

| Claim     | Description               |
|-----------|---------------------------|
| `sub`     | User ID                   |
| `exp`     | Expiry timestamp          |
| `iat`     | Issued-at timestamp       |

The application server validates the JWT signature against the shared secret or public key.
Expired or tampered tokens are rejected with `401`.

### 2. Action Token — Proof of Legitimate Action Completion

This is the key mechanism preventing score manipulation.

**Flow:**
    1. User starts an action
    2. Server issues a signed, single-use action_token (stored in DB with status = "pending")
    3. User completes the action on the client
    4. Client sends action_token + JWT to POST /api/scores/update
    5. Server verifies:
        - token signature is valid
        - token belongs to the authenticated user (Use JWT sub get token on DB and verify equal with token user send)
        - token status == "pending" (not already used)
        - token has not expired
    6. Server atomically:
        - marks token status = "consumed"
        - increments user score
        - broadcasts updated scoreboard

Without the action token, a malicious user cannot call the score update endpoint directly —
they would have no valid token to present.

**Token properties:**

| Property   | Value                                     |
|------------|-------------------------------------------|
| Format     | Signed opaque string (HMAC-SHA256 or JWT) |
| TTL        | 10 minutes                                |
| Single-use | Yes — consumed on first use               |
| Bound to   | User ID (prevents token sharing)          |

### 3. Rate Limiting

Score update requests are rate-limited per user:

| Window  | Max requests |
|---------|--------------|
| 1 minute | 10 requests |
| 1 hour   | 100 requests |

Responses exceeding the limit receive `429 Too Many Requests`.

---

### 4. HTTPS Only

All HTTP traffic must be served over TLS. Plaintext connections must be rejected or redirected.

---

## Real-time Delivery

### WebSocket Broadcast Flow

After a successful score update:

1. Score is written to the database.
2. Server queries top 10 scores from DB.
3. Server broadcasts `scoreboard_update` event to all active WebSocket connections.
4. Each connected client updates its UI.

## Data Model

### `users` table

| Column       | Type        | Notes               |
|--------------|-------------|---------------------|
| `id`         | UUID PK     |                     |
| `username`   | VARCHAR(64) | Unique              |
| `score`      | INTEGER     | Default 0           |
| `created_at` | TIMESTAMP   |                     |
| `updated_at` | TIMESTAMP   |                     |

### `action_tokens` table

| Column       | Type        | Notes                                |
|--------------|-------------|--------------------------------------|
| `id`         | UUID PK     |                                      |
| `user_id`    | UUID FK     | References `users.id`                |
| `token`      | VARCHAR     | Signed token string                  |
| `status`     | ENUM        | `pending` \| `consumed` \| `expired` |
| `expires_at` | TIMESTAMP   | 10 minutes from creation             |
| `created_at` | TIMESTAMP   |                                      |
| `consumed_at`| TIMESTAMP   | Null until used                      |

## Sequence Diagram
 
    Client                                                 API Server                            Database                                  WS clients
+--------------------------------------------------------------------------------------------------------------------------------------------------------+
      |                                                         |                                    |                                         |
User open page ----(WSS connect)------------------------> Register client -------------------->  Fetch top 10                                  |
      |<----------(Top 10 snapshot)-----------------------------| <----------------------------------|                                         |
      |                                                         |                                    |                                         |
      |                                                         |                                    |                                         |
User start action ----------------------------------------> Issue token -----------------> store token status=pending                          |
      |<----------(action token)--------------------------------|<-----------------------------------|                                         |
      |                                                         |                                    |                                         |
      |                                                         |                                    |                                         |
Action complete                                             Verify JWT                               |                                         |
POST /api/score/update------------------------------------> Extract user_id                          |                                         |
      |                                                   Validate token                             |                                         |
      |                                                (sig + user + status)---------------------> Found                                       |
      |                                                          |<----------------------------------|                                         |
      |                                                          |-------------------------------> Write DB (token=consumed, new score)        |
      |                                                    Fetch new top 10----------------------> Fetch top 10                                |
      |                                                          |<----------------------------------|                                         |
      |                                                    Broadcast update ------------------------------------------------------------> All client
      | <------------200 new score ------------------------------|                                   |                                         |
Error case:                   
      | <------------401-----------------------------------JWT invalid                               |                                         |
      | <------------403-----------------------------------Token consumed                            |                                         |
      | <------------429-----------------------------------Rate limit hit                            |                                         |

## Technical Constraints & Notes
### 1. Race Condition Prevention (Database Locking)
* **Requirement:** When updating sensitive data (such as user scores or account balances), the system must implement proper **concurrency control** to prevent race conditions.
* **Implementation:** * Use **Pessimistic Locking** (e.g., `SELECT ... FOR UPDATE` in SQL) or **Optimistic Locking** (versioning) depending on the database architecture.
  * Alternatively, leverage atomic operations (e.g., `UPDATE users SET score = score + :delta WHERE id = :id`) to guarantee data integrity under high concurrent traffic.
### 2. Error Handling
  * The server must **never** reveal internal details (stack traces, DB errors) in error responses.
  * Log them server-side and return a generic message for `500` errors.
