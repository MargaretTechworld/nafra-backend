# NAFRA Backend Setup & Workflow

## Initial Setup (First Time Only)

### Step 1: Create Admin User
Use the **Admin Setup** endpoint (only works when no users exist):

```bash
curl -X POST http://localhost:3000/api/auth/admin-setup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Admin User",
    "email": "admin@example.com",
    "password": "SecurePass123!",
    "password_confirmation": "SecurePass123!"
  }'
```

**Response:**
```json
{
  "message": "Admin user created successfully",
  "user_id": 1,
  "name": "Admin User",
  "email": "admin@example.com",
  "role": "admin",
  "token": "eyJhbGc..."
}
```

**Save the token** - you'll use this to create agencies!

---

## Creating Agencies (After Admin Setup)

### Recommended: Use Agency Setup Endpoint
Create agency + user in one atomic transaction with auto-generated credentials:

```bash
curl -X POST http://localhost:3000/api/auth/agency-setup \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <admin_token>" \
  -d '{
    "name": "John Doe",
    "agency_name": "Agency 1",
    "ministry": "Ministry of Agriculture"
  }'
```

**What gets auto-generated:**
- Email: `john.doe@agency.com` (from name)
- Password: Random secure password (shown in response)
- Project Name: Same as agency_name
- Role: `"agency"`

**Response:**
```json
{
  "message": "Agency and user created successfully",
  "user": {
    "user_id": 2,
    "name": "John Doe",
    "email": "john.doe@agency.com",
    "role": "agency",
    "password": "AutGenPWD123=="
  },
  "agency": {
    "agency_id": 1,
    "name": "Agency 1",
    "project_name": "Agency 1",
    "ministry": "Ministry of Agriculture",
    "user_id": 2
  }
}
```

---

## User Login

After setup, any user can log in:

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@agency.com",
    "password": "AutGenPWD123=="
  }'
```

**Response:**
```json
{
  "token": "eyJhbGc...",
  "role": "agency",
  "user_id": 2
}
```

Use this token in the `Authorization: Bearer <token>` header for all subsequent requests.

---

## API Endpoints Overview

### Authentication
- `POST /api/auth/admin-setup` - Create initial admin (first time only)
- `POST /api/auth/agency-setup` - Create agency + user (recommended)
- `POST /api/auth/register` - Create user manually (alternative)
- `POST /api/auth/login` - Get JWT token

### Submissions (Agency Users)
- `GET /api/submissions` - List submissions (paginated)
- `POST /api/submissions` - Create new submission

### Admin Only
- `GET /api/admin/users` - List all users
- `GET /api/admin/users/:id` - Get user details
- `POST /api/admin/users` - Create user
- `PATCH /api/admin/users/:id` - Update user
- `GET /api/admin/agencies` - List all agencies
- `GET /api/admin/agencies/:id` - Get agency details
- `POST /api/admin/agencies` - Create agency
- `PATCH /api/admin/agencies/:id` - Update agency
- `GET /api/admin/analytics/bags-by-district` - Distribution by district
- `GET /api/admin/analytics/bags-by-agency` - Distribution by agency
- `GET /api/admin/analytics/bags-by-fertilizer` - Distribution by fertilizer
- `GET /api/admin/analytics/agency-district-distribution` - Detailed breakdown

---

## Transaction Safety

The `agency-setup` endpoint uses database transactions:
- Both user and agency creation succeeds, or both are rolled back
- No orphaned records
- Atomic operation - guaranteed consistency

---

## Features

✅ **Auto-Generated Credentials**
- Email derived from user name
- Secure random password
- No manual entry needed for UI forms

✅ **Atomic Transactions**
- User and agency created together
- Automatic rollback on failure
- Data consistency guaranteed

✅ **Two Setup Workflows**
- Simple: Use `admin-setup` then `agency-setup`
- Manual: Use `register` and `agencies` endpoints for full control

✅ **Security**
- JWT token authentication
- Role-based authorization (admin/agency)
- Rate limiting on login
- Password hashing with bcrypt

✅ **Error Handling**
- Validation errors reported clearly
- Transaction rollback on failure
- Detailed error messages

---

## Example: Complete Setup Flow

1. **Initialize system with admin:**
   ```bash
   POST /api/auth/admin-setup
   {
     "name": "System Admin",
     "email": "admin@example.com",
     "password": "AdminPass123!",
     "password_confirmation": "AdminPass123!"
   }
   ```
   Copy the returned `token`

2. **Create first agency:**
   ```bash
   POST /api/auth/agency-setup
   Header: Authorization: Bearer <admin_token>
   {
     "name": "Jane Smith",
     "agency_name": "North District Agency",
     "ministry": "Ministry of Agriculture"
   }
   ```

3. **Agency user logs in:**
   ```bash
   POST /api/auth/login
   {
     "email": "jane.smith@agency.com",
     "password": "AutGenPWD123=="
   }
   ```

4. **Submit fertilizer distribution:**
   ```bash
   POST /api/submissions
   Header: Authorization: Bearer <agency_user_token>
   {
     "submitted_at": "2026-01-25T10:00:00Z",
     "items": [
       {
         "district_id": 1,
         "chiefdom_id": 1,
         "fertilizer_id": 1,
         "dealer_id": 1,
         "bags_25kg": 100,
         "bags_50kg": 50
       }
     ]
   }
   ```

Done! ✅
