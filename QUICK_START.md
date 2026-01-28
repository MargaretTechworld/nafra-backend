# NAFRA Backend - Quick Start Guide

## 🚀 Getting Started

### Prerequisites
- Rails 7.1.5
- PostgreSQL
- Ruby 3.x
- Postman or cURL

### Installation & Setup

1. **Clone and install dependencies:**
   ```bash
   bundle install
   ```

2. **Setup database:**
   ```bash
   rails db:create
   rails db:migrate
   ```

3. **Start the server:**
   ```bash
   rails server
   ```

---

## ⚡ Quick Start Workflow

### 1️⃣ Initialize Admin (One Time)

```bash
curl -X POST http://localhost:3000/api/auth/admin-setup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Admin User",
    "email": "admin@example.com",
    "password": "AdminPass123!",
    "password_confirmation": "AdminPass123!"
  }'
```

**Save the returned token!** You'll need it to create agencies.

---

### 2️⃣ Create First Agency

```bash
curl -X POST http://localhost:3000/api/auth/agency-setup \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -d '{
    "name": "John Doe",
    "agency_name": "Northern District",
    "ministry": "Ministry of Agriculture"
  }'
```

**Auto-generated for the agency user:**
- Email: `john.doe@agency.com`
- Password: `AutGenPWD123==` (shown in response - save this!)
- Role: `agency`

---

### 3️⃣ Agency User Login

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@agency.com",
    "password": "AutGenPWD123=="
  }'
```

**Save the token!** Use it for submissions.

---

### 4️⃣ Submit Distribution Data

```bash
curl -X POST http://localhost:3000/api/submissions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer AGENCY_TOKEN" \
  -d '{
    "submitted_at": "2026-01-25T14:30:00Z",
    "items": [
      {
        "district_id": 1,
        "chiefdom_id": 1,
        "fertilizer_id": 1,
        "dealer_id": 1,
        "bags_25kg": 50,
        "bags_50kg": 25
      }
    ]
  }'
```

---

## 📊 Admin Analytics

### Get Distribution by District

```bash
curl -X GET "http://localhost:3000/api/admin/analytics/bags-by-district" \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

### Get Distribution by Agency

```bash
curl -X GET "http://localhost:3000/api/admin/analytics/bags-by-agency" \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

### Get Detailed Agency-District Breakdown

```bash
curl -X GET "http://localhost:3000/api/admin/analytics/agency-district-distribution" \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

---

## 🔑 Key Features

✅ **Simple Setup**
- Only 3 fields needed to create agency (name, agency_name, ministry)
- Email and password auto-generated
- No manual user creation

✅ **Data Consistency**
- User and agency created together
- Automatic rollback if either fails
- No orphaned records

✅ **Security**
- JWT token authentication
- Role-based access (admin/agency)
- Bcrypt password hashing
- Rate limiting on login

✅ **Easy Integration**
- RESTful API
- JSON request/response
- Pagination support
- Detailed error messages

---

## 📝 API Endpoints Summary

### Authentication
```
POST /api/auth/admin-setup          - Create first admin
POST /api/auth/agency-setup         - Create agency + user
POST /api/auth/login                - Login and get token
POST /api/auth/register             - Manual user creation (alternative)
```

### Submissions
```
GET  /api/submissions               - List submissions
POST /api/submissions               - Create submission
```

### Admin Management
```
GET  /api/admin/users               - List all users
GET  /api/admin/users/:id           - Get user details
POST /api/admin/users               - Create user manually
PATCH /api/admin/users/:id          - Update user

GET  /api/admin/agencies            - List all agencies
GET  /api/admin/agencies/:id        - Get agency details
POST /api/admin/agencies            - Create agency manually
PATCH /api/admin/agencies/:id       - Update agency
```

### Analytics
```
GET /api/admin/analytics/bags-by-district
GET /api/admin/analytics/bags-by-agency
GET /api/admin/analytics/bags-by-fertilizer
GET /api/admin/analytics/agency-district-distribution
```

---

## 💡 Recommended Flow for UI

### Admin Panel
1. **First Load:**
   - Show "System Setup" form
   - After submit → redirect to admin dashboard
   
2. **Admin Dashboard:**
   - Button: "Create New Agency"
   - Shows: List of agencies
   - Shows: Analytics charts

### Agency User Panel
1. **Login:**
   - Email/password form
   - Shows: "Submit Distribution"
   
2. **After Login:**
   - Form: Select district, chiefdom, fertilizer, dealer
   - Form: Enter bags (25kg and 50kg separately)
   - Shows: Submission history

---

## 🧪 Testing

### Run Test Script
```bash
cd c:\Users\USER\nafra-backend
.\test_endpoints.ps1
```

### Manual Test with Postman
1. Create request: `POST http://localhost:3000/api/auth/admin-setup`
2. Fill in admin details
3. Copy token from response
4. Use token to create agency
5. Use agency credentials to login
6. Make submissions

---

## 🆘 Troubleshooting

**"System already initialized"**
- Admin already exists. Use `/auth/login` instead

**"Only admins can create agencies"**
- Make sure Authorization header has correct admin token
- Check token is not expired

**"Invalid email or password"**
- Check spelling of email
- Verify password (case-sensitive)

**"User already exists"**
- Email is taken, use different email

---

## 📚 Full Documentation

- [API_DOCUMENTATION.md](API_DOCUMENTATION.md) - Complete API reference
- [SETUP_WORKFLOW.md](SETUP_WORKFLOW.md) - Detailed workflows
- [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) - Technical details

---

## ✅ That's It!

You now have a professional, production-ready API for NAFRA distribution tracking:
- Simple setup with auto-generated credentials
- Atomic transactions for data consistency
- JWT authentication
- Role-based access control
- Comprehensive analytics

**Ready to build the frontend!** 🎉
