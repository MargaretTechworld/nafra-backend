# NAFRA System Architecture - After Implementation

## System Overview

```
┌────────────────────────────────────────────────────────────────┐
│                     NAFRA Backend API                          │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │ AUTHENTICATION LAYER                                     │ │
│  │                                                          │ │
│  │ 1. Admin Setup (First Time Only)                        │ │
│  │    POST /api/auth/admin-setup                           │ │
│  │    No auth required                                     │ │
│  │    → Returns: admin token                               │ │
│  │                                                          │ │
│  │ 2. Agency Setup (Repeatable)                            │ │
│  │    POST /api/auth/agency-setup                          │ │
│  │    Requires: admin token                                │ │
│  │    Auto-generates: email, password                      │ │
│  │    → Returns: user + agency + password                  │ │
│  │                                                          │ │
│  │ 3. Login                                                │ │
│  │    POST /api/auth/login                                 │ │
│  │    → Returns: JWT token                                 │ │
│  │                                                          │ │
│  │ 4. Register (Alternative)                               │ │
│  │    POST /api/auth/register                              │ │
│  │    Requires: admin token                                │ │
│  │    → Returns: user details                              │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │ SUBMISSION LAYER (Agency Users)                         │ │
│  │                                                          │ │
│  │ GET  /api/submissions          (List + paginate)        │ │
│  │ POST /api/submissions          (Create + validate)      │ │
│  │                                                          │ │
│  │ Requires: Agency user token                             │ │
│  │ Features: Separate 25kg/50kg counts                     │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │ ADMIN LAYER (Admin Only)                                │ │
│  │                                                          │ │
│  │ Users Management:                                       │ │
│  │   GET    /api/admin/users          (List)              │ │
│  │   GET    /api/admin/users/:id      (Show)              │ │
│  │   POST   /api/admin/users          (Create)            │ │
│  │   PATCH  /api/admin/users/:id      (Update)            │ │
│  │                                                          │ │
│  │ Agencies Management:                                    │ │
│  │   GET    /api/admin/agencies       (List)              │ │
│  │   GET    /api/admin/agencies/:id   (Show)              │ │
│  │   POST   /api/admin/agencies       (Create)            │ │
│  │   PATCH  /api/admin/agencies/:id   (Update)            │ │
│  │                                                          │ │
│  │ Analytics:                                              │ │
│  │   GET /api/admin/analytics/bags-by-district            │ │
│  │   GET /api/admin/analytics/bags-by-agency              │ │
│  │   GET /api/admin/analytics/bags-by-fertilizer          │ │
│  │   GET /api/admin/analytics/agency-district-dist...     │ │
│  │                                                          │ │
│  │ Requires: Admin token                                   │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

---

## User Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                   FIRST TIME SETUP (Admin)                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Frontend                    API                    Database     │
│                                                                 │
│ [Admin Setup Form]                                             │
│ - name                                                          │
│ - email                                                         │
│ - password                                                      │
│        │                                                        │
│        ├─ POST /admin-setup ──────→ Check: no users exist  │
│        │                            └─ Create user (admin)  │
│        │                            └─ Encode JWT token       │
│        │                            └─ Return token           │
│        │                                                │       │
│        ←────────── JSON (token) ─────────────────────┘       │
│        │                                                        │
│ [Save Token] ◄─────── Use for creating agencies             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│             CREATE AGENCIES (Admin Repeating)                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Frontend                    API                    Database     │
│                                                                 │
│ [Create Agency Form]                                           │
│ - name                                                          │
│ - agency_name                                                   │
│ - ministry (optional)                                           │
│        │                                                        │
│        ├─ POST /agency-setup ─────→ Verify admin token        │
│        │ Header: Bearer <token>     └─ Transaction START       │
│        │                            └─ Create user:            │
│        │                               * Auto email             │
│        │                               * Auto password          │
│        │                               * Role: agency           │
│        │                            └─ Create agency:           │
│        │                               * Linked to user         │
│        │                               * Project_name default   │
│        │                            └─ Return both + password  │
│        │                                                │       │
│        ←───── JSON (user + agency) ─────────────────┘       │
│        │                                                        │
│ [Display Password] ◄─────── Show to admin to share           │
│ [Save Credentials]                                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│          AGENCY USER LOGIN & SUBMISSION                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Frontend                    API                    Database     │
│                                                                 │
│ [Login Form]                                                   │
│ - email                                                         │
│ - password                                                      │
│        │                                                        │
│        ├─ POST /login ───────────→ Find user by email          │
│        │                          └─ Verify password           │
│        │                          └─ Generate JWT token        │
│        │                          └─ Return token              │
│        │                                                │       │
│        ←────── JSON (token) ─────────────────────────┘       │
│        │                                                        │
│ [Save Token]                                                   │
│                                                                 │
│ [Submit Distribution Form]                                    │
│ - district                                                      │
│ - chiefdom                                                      │
│ - fertilizer                                                    │
│ - dealer                                                        │
│ - bags_25kg                                                     │
│ - bags_50kg                                                     │
│        │                                                        │
│        ├─ POST /submissions ───────→ Verify auth token         │
│        │ Header: Bearer <token>     └─ Validate agency access  │
│        │                            └─ Create submission        │
│        │                            └─ Create submission_items  │
│        │                            └─ Return submission        │
│        │                                                │       │
│        ←───── JSON (submission) ───────────────────────┘       │
│        │                                                        │
│ [Display Success] ◄─────── Show submission ID & details      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│           ADMIN ANALYTICS & MANAGEMENT                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Frontend                    API                    Database     │
│                                                                 │
│ [Admin Dashboard]                                              │
│                                                                 │
│ Get Analytics:                                                 │
│ ├─ GET /analytics/bags-by-district                            │
│ ├─ GET /analytics/bags-by-agency                              │
│ ├─ GET /analytics/bags-by-fertilizer                          │
│ └─ GET /analytics/agency-district-distribution               │
│        │                                                        │
│        ├─ All with Bearer <admin_token>                       │
│        │                                                        │
│        ├─ Query: Sum bags_25kg and bags_50kg separately       │
│        │                                                        │
│        ←───── JSON (analytics) ──────────────────────────┘     │
│                                                                 │
│ Manage Users:                                                  │
│ ├─ GET    /admin/users          (List all)                    │
│ ├─ GET    /admin/users/:id      (Show one)                    │
│ ├─ POST   /admin/users          (Create)                      │
│ └─ PATCH  /admin/users/:id      (Update)                      │
│                                                                 │
│ Manage Agencies:                                               │
│ ├─ GET    /admin/agencies       (List all)                    │
│ ├─ GET    /admin/agencies/:id   (Show one)                    │
│ ├─ POST   /admin/agencies       (Create)                      │
│ └─ PATCH  /admin/agencies/:id   (Update)                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Data Model Relationship

```
┌──────────────────────────────────────────────────────────────┐
│                   DATABASE SCHEMA                            │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────┐         ┌──────────────────┐           │
│  │     users       │         │    agencies      │           │
│  ├─────────────────┤         ├──────────────────┤           │
│  │ id (PK)         │◄────────│ id (PK)          │           │
│  │ name            │1:1      │ name             │           │
│  │ email (unique)  │         │ project_name     │           │
│  │ password_digest │         │ ministry         │           │
│  │ role            │         │ user_id (FK)     │           │
│  │ created_at      │         │ created_at       │           │
│  │ updated_at      │         │ updated_at       │           │
│  └─────────────────┘         └──────────────────┘           │
│         ▲                                                    │
│         │                                                    │
│         │ 1:N                                                │
│         │                                                    │
│  ┌──────────────────────┐                                    │
│  │   submissions        │                                    │
│  ├──────────────────────┤                                    │
│  │ id (PK)              │                                    │
│  │ agency_id (FK)       │                                    │
│  │ submitted_by (FK)────┼──→ users                           │
│  │ submitted_at         │                                    │
│  │ created_at           │                                    │
│  │ updated_at           │                                    │
│  └──────────────────────┘                                    │
│         │                                                    │
│         │ 1:N                                                │
│         │                                                    │
│  ┌──────────────────────┐                                    │
│  │ submission_items     │                                    │
│  ├──────────────────────┤                                    │
│  │ id (PK)              │                                    │
│  │ submission_id (FK)   │──→ submissions                     │
│  │ district_id (FK)     │──→ districts                       │
│  │ chiefdom_id (FK)     │──→ chiefdoms                       │
│  │ fertilizer_id (FK)   │──→ fertilizers                     │
│  │ dealer_id (FK)       │──→ dealers                         │
│  │ bags_25kg (int)      │    (separate counts)              │
│  │ bags_50kg (int)      │                                    │
│  │ created_at           │                                    │
│  │ updated_at           │                                    │
│  └──────────────────────┘                                    │
│                                                              │
│  ┌─────────────────┐  ┌──────────────────┐                  │
│  │   districts     │  │   chiefdoms      │                  │
│  ├─────────────────┤  ├──────────────────┤                  │
│  │ id (PK)         │  │ id (PK)          │                  │
│  │ name            │  │ name             │                  │
│  │ created_at      │  │ district_id (FK) │                  │
│  │ updated_at      │  │ created_at       │                  │
│  └─────────────────┘  │ updated_at       │                  │
│                       └──────────────────┘                  │
│                                                              │
│  ┌─────────────────┐  ┌──────────────────┐                  │
│  │  fertilizers    │  │     dealers      │                  │
│  ├─────────────────┤  ├──────────────────┤                  │
│  │ id (PK)         │  │ id (PK)          │                  │
│  │ name            │  │ name             │                  │
│  │ type            │  │ location         │                  │
│  │ created_at      │  │ created_at       │                  │
│  │ updated_at      │  │ updated_at       │                  │
│  └─────────────────┘  └──────────────────┘                  │
│                                                              │
└──────────────────────────────────────────────────────────────┘

Key Features:
✓ users.role = 'admin' or 'agency'
✓ agencies.user_id links agency to user (1:1)
✓ submissions.agency_id links to agency
✓ submissions.submitted_by links to user
✓ submission_items has bags_25kg and bags_50kg SEPARATE (not summed)
✓ All foreign keys have indexes for performance
✓ All nullable fields properly handled
```

---

## Authentication & Authorization Flow

```
┌──────────────────────────────────────────────────────────────┐
│              TOKEN & AUTHORIZATION FLOW                      │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│ 1. User submits credentials                                 │
│    ↓                                                         │
│ 2. API validates credentials                                │
│    ↓                                                         │
│ 3. API generates JWT token:                                 │
│    {                                                         │
│      "user_id": 1,                                           │
│      "iat": 1234567890,                                      │
│      "exp": future_timestamp                                 │
│    }                                                         │
│    ↓                                                         │
│ 4. Token returned to client                                 │
│    ↓                                                         │
│ 5. Client sends token in header:                            │
│    Authorization: Bearer <token>                            │
│    ↓                                                         │
│ 6. API receives request                                     │
│    ↓                                                         │
│ 7. authenticate_user! filter:                               │
│    - Extracts token from header                             │
│    - Decodes JWT                                             │
│    - Verifies signature                                     │
│    - Checks expiration                                      │
│    - Sets @current_user                                     │
│    ↓                                                         │
│ 8. Authorization checks (if needed):                        │
│    - Is @current_user admin?                                │
│    - Does @current_user own this agency?                    │
│    ↓                                                         │
│ 9. Request processed or denied                              │
│                                                              │
│ Token Validation Process:                                   │
│ ┌────────────────────────────────────────────────────────┐  │
│ │ JWT.decode(token, secret_key)                          │  │
│ │   ↓                                                     │  │
│ │ Verify signature (ensures token wasn't tampered)      │  │
│ │   ↓                                                     │  │
│ │ Extract payload { user_id: X }                         │  │
│ │   ↓                                                     │  │
│ │ Check expiration (if present)                          │  │
│ │   ↓                                                     │  │
│ │ Find User by user_id                                   │  │
│ │   ↓                                                     │  │
│ │ Token valid ✓  OR  Token invalid ✗                    │  │
│ └────────────────────────────────────────────────────────┘  │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## Security Features

```
┌──────────────────────────────────────────────────────────────┐
│                  SECURITY MEASURES                           │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│ ✓ Passwords                                                 │
│   - Hashed with bcrypt (10+ rounds)                         │
│   - Never stored in plain text                              │
│   - Validated for minimum length                            │
│                                                              │
│ ✓ Authentication                                            │
│   - JWT tokens with secret key                              │
│   - Token-based (not session-based)                         │
│   - Can be expired (future enhancement)                     │
│                                                              │
│ ✓ Authorization                                             │
│   - Role-based (admin vs agency)                            │
│   - Agency users can only see own data                      │
│   - Admin users can see everything                          │
│                                                              │
│ ✓ Rate Limiting                                             │
│   - Login: 5 requests/min per IP                            │
│   - Login: 5 requests/min per email                         │
│   - API: 100 requests/min per IP                            │
│                                                              │
│ ✓ Data Validation                                           │
│   - All inputs validated                                    │
│   - Type checking                                           │
│   - Format validation (email, etc)                          │
│   - Presence validation                                     │
│                                                              │
│ ✓ CORS                                                      │
│   - Configured for trusted origins only                     │
│   - localhost:3000, 3001, 8080                              │
│   - Environment variable for production                     │
│                                                              │
│ ✓ Database                                                  │
│   - Foreign key constraints                                 │
│   - NOT NULL constraints                                    │
│   - Indexes for security queries                            │
│   - Unique constraints (email)                              │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## Performance Optimizations

```
┌──────────────────────────────────────────────────────────────┐
│              PERFORMANCE FEATURES                            │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│ ✓ Database Indexes                                          │
│   - users(email) - for login                                │
│   - submissions(agency_id) - for filtering                  │
│   - submission_items(submission_id) - for relationships     │
│   - submission_items(district_id, fertilizer_id) - analytics│
│                                                              │
│ ✓ Eager Loading                                             │
│   - Include associations in queries                         │
│   - Avoid N+1 query problems                                │
│   - Optimized SELECT statements                             │
│                                                              │
│ ✓ Pagination                                                │
│   - 20 items per page default                               │
│   - Metadata: current_page, total_pages, total_count        │
│   - Reduces payload size                                    │
│                                                              │
│ ✓ Serializers                                               │
│   - Return only needed fields                               │
│   - Consistent JSON structure                               │
│   - Avoid N+1 with includes                                 │
│                                                              │
│ ✓ Transaction Grouping                                      │
│   - Multiple operations in one transaction                  │
│   - Atomic all-or-nothing semantics                         │
│   - Single database round-trip                              │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## Summary

The NAFRA system now has:

✅ **Professional Setup Flow**
- Admin initialization (one-time)
- Agency creation with auto-generated credentials
- Atomic transactions for consistency

✅ **Clean Architecture**
- RESTful API endpoints
- Role-based authorization
- Consistent error handling

✅ **Production Ready**
- Security features enabled
- Performance optimized
- Fully documented

✅ **Easy Integration**
- Simple 3-field agency form
- Auto-generated passwords
- Minimal frontend complexity

🚀 **Ready to build the frontend!**
