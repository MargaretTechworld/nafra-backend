# NAFRA Backend API Documentation

## Base URL
```
http://localhost:3000/api
```

## Authentication
All endpoints (except login) require JWT authentication via the `Authorization` header:
```
Authorization: Bearer <token>
```

---

## Authentication Endpoints

### Admin Setup (First Time Only)
**POST** `/auth/admin-setup`

Create the initial admin user. This endpoint only works when no users exist in the system (first time setup).

**Request:**
```json
{
  "name": "Admin User",
  "email": "admin@example.com",
  "password": "password123",
  "password_confirmation": "password123"
}
```

**Response (201 Created):**
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

**Response (403 Forbidden - Already Initialized):**
```json
{
  "error": "System already initialized. Admin user already exists."
}
```

### Agency Setup (Recommended)
**POST** `/auth/agency-setup`

Create a new agency with an associated user in one atomic transaction. Requires admin authentication. All user and agency details must be entered manually.

**Headers:**
```
Authorization: Bearer <admin_token>
```

**Request:**
```json
{
  "name": "John Doe",
  "email": "john.doe@example.com",
  "password": "SecurePass123!",
  "password_confirmation": "SecurePass123!",
  "agency_name": "Northern District Office",
  "project_name": "Fertilizer Distribution Phase 2",
  "ministry": "Ministry of Agriculture"
}
```

**Response (201 Created):**
```json
{
  "message": "Agency and user created successfully",
  "user": {
    "user_id": 2,
    "name": "John Doe",
    "email": "john.doe@example.com",
    "role": "agency"
  },
  "agency": {
    "agency_id": 1,
    "name": "Northern District Office",
    "project_name": "Fertilizer Distribution Phase 2",
    "ministry": "Ministry of Agriculture",
    "user_id": 2
  }
}
```

**Response (401 Unauthorized - Missing Token):**
```json
{
  "error": "Missing or invalid authorization token"
}
```

**Response (403 Forbidden - Non-Admin):**
```json
{
  "error": "Only admins can create agencies"
}
```

**Response (422 Unprocessable Entity - Validation Error):**
```json
{
  "errors": [
    "Email has already been taken",
    "Password is too short (minimum is 8 characters)"
  ]
}
```

### Login
**POST** `/auth/login`

Create a new JWT token using email and password.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGc...",
  "role": "agency",
  "user_id": 2
}
```

**Response (401 Unauthorized):**
```json
{
  "error": "Invalid email or password"
}
```

**Rate Limiting:**
- Max 5 requests per minute per IP
- Max 5 requests per minute per email

---

## Admin Management Endpoints (Admin Only)

All admin management endpoints require admin authentication.

### Users Management

#### List All Users
**GET** `/admin/users`

Get all users in the system.

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "Admin User",
    "email": "admin@example.com",
    "role": "admin",
    "agency": null,
    "created_at": "2026-01-25T10:00:00.000Z",
    "updated_at": "2026-01-25T10:00:00.000Z"
  },
  {
    "id": 2,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "agency",
    "agency": {
      "id": 1,
      "name": "Agency 1"
    },
    "created_at": "2026-01-25T11:00:00.000Z",
    "updated_at": "2026-01-25T11:00:00.000Z"
  }
]
```

#### Get Single User
**GET** `/admin/users/:id`

Get details of a specific user.

**Response (200 OK):**
```json
{
  "id": 2,
  "name": "John Doe",
  "email": "john@example.com",
  "role": "agency",
  "agency": {
    "id": 1,
    "name": "Agency 1"
  },
  "created_at": "2026-01-25T11:00:00.000Z",
  "updated_at": "2026-01-25T11:00:00.000Z"
}
```

#### Create User
**POST** `/admin/users`

Create a new user.

**Request:**
```json
{
  "name": "Jane Smith",
  "email": "jane@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "role": "agency"
}
```

**Response (201 Created):**
```json
{
  "id": 3,
  "name": "Jane Smith",
  "email": "jane@example.com",
  "role": "agency",
  "agency": null,
  "created_at": "2026-01-25T12:00:00.000Z",
  "updated_at": "2026-01-25T12:00:00.000Z"
}
```

#### Update User
**PUT/PATCH** `/admin/users/:id`

Update user details (name, role, password).

**Request:**
```json
{
  "name": "Jane Smith Updated",
  "role": "admin",
  "password": "newpassword123",
  "password_confirmation": "newpassword123"
}
```

**Response (200 OK):**
```json
{
  "id": 3,
  "name": "Jane Smith Updated",
  "email": "jane@example.com",
  "role": "admin",
  "agency": null,
  "created_at": "2026-01-25T12:00:00.000Z",
  "updated_at": "2026-01-25T12:30:00.000Z"
}
```

### Agencies Management

#### List All Agencies
**GET** `/admin/agencies`

Get all agencies in the system.

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "Agency 1",
    "project_name": "Project Alpha",
    "ministry": "Ministry of Agriculture",
    "user": {
      "id": 2,
      "name": "John Doe",
      "email": "john@example.com"
    },
    "created_at": "2026-01-25T11:00:00.000Z",
    "updated_at": "2026-01-25T11:00:00.000Z"
  }
]
```

#### Get Single Agency
**GET** `/admin/agencies/:id`

Get details of a specific agency.

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "Agency 1",
  "project_name": "Project Alpha",
  "ministry": "Ministry of Agriculture",
  "user": {
    "id": 2,
    "name": "John Doe",
    "email": "john@example.com"
  },
  "created_at": "2026-01-25T11:00:00.000Z",
  "updated_at": "2026-01-25T11:00:00.000Z"
}
```

#### Create Agency
**POST** `/admin/agencies`

Create a new agency and link it to an existing user.

**Request:**
```json
{
  "name": "Agency 2",
  "project_name": "Project Beta",
  "ministry": "Ministry of Education",
  "user_id": 3
}
```

**Response (201 Created):**
```json
{
  "id": 2,
  "name": "Agency 2",
  "project_name": "Project Beta",
  "ministry": "Ministry of Education",
  "user": {
    "id": 3,
    "name": "Jane Smith",
    "email": "jane@example.com"
  },
  "created_at": "2026-01-25T12:00:00.000Z",
  "updated_at": "2026-01-25T12:00:00.000Z"
}
```

**Response (400 Bad Request):**
```json
{
  "error": "User must have agency role"
}
```

#### Update Agency
**PUT/PATCH** `/admin/agencies/:id`

Update agency details.

**Request:**
```json
{
  "name": "Agency 2 Updated",
  "project_name": "Project Beta v2",
  "ministry": "Ministry of Education"
}
```

**Response (200 OK):**
```json
{
  "id": 2,
  "name": "Agency 2 Updated",
  "project_name": "Project Beta v2",
  "ministry": "Ministry of Education",
  "user": {
    "id": 3,
    "name": "Jane Smith",
    "email": "jane@example.com"
  },
  "created_at": "2026-01-25T12:00:00.000Z",
  "updated_at": "2026-01-25T12:30:00.000Z"
}
```

---

## Submissions Endpoints

### List Submissions
**GET** `/submissions`

Retrieve all submissions. Admin users see all submissions, agency users see only their own.

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `per_page` (optional): Items per page (default: 20)

**Response (200 OK):**
```json
{
  "submissions": [
    {
      "id": 1,
      "agency": {
        "id": 1,
        "name": "Agency Name",
        "project_name": "Project Name"
      },
      "submitted_by": {
        "id": 2,
        "name": "John Doe",
        "email": "john@example.com"
      },
      "submitted_at": "2026-01-25",
      "created_at": "2026-01-25T12:00:00.000Z",
      "updated_at": "2026-01-25T12:00:00.000Z",
      "submission_items": [...],
      "total_bags_25kg": 100,
      "total_bags_50kg": 50
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 100,
    "per_page": 20
  }
}
```

### Create Submission (Direct)
**POST** `/submissions`

Directly submit fertilizer distribution data without a draft.

**Request:**
```json
{
  "agency_id": 1,
  "submitted_at": "2026-01-25",
  "items": [
    {
      "district_id": 1,
      "chiefdom_id": 1,
      "fertilizer_id": 1,
      "dealer_id": 1,
      "bags_25kg": 10,
      "bags_50kg": 5
    }
  ]
}
```

**Notes:**
- For agency users, `agency_id` is optional and defaults to their own agency
- Admin users can submit for any agency by providing `agency_id`
- At least one bag size (bags_25kg or bags_50kg) must be provided per item
- `submitted_at` cannot be in the future

---

## Technical Notes

### Draft Submission Flow
The conversion from Draft to Submission is handled as an atomic transaction via the `Draft#submit!(user)` method. If any part of the process fails (e.g., database constraint error), the entire operation is rolled back, and the draft remains in 'draft' status.

---

---

## Analytics Endpoints (Admin Only)

### Bags by District
**GET** `/admin/analytics/bags-by-district`

Get total bags distributed per district, broken down by bag size.

**Response (200 OK):**
```json
[
  {
    "district": "District 1",
    "bags_25kg": 300,
    "bags_50kg": 200
  },
  {
    "district": "District 2",
    "bags_25kg": 450,
    "bags_50kg": 300
  },
  {
    "district": "District 3",
    "bags_25kg": 200,
    "bags_50kg": 100
  }
]
```

### Bags by Agency
**GET** `/admin/analytics/bags-by-agency`

Get total bags distributed per agency, broken down by bag size.

**Response (200 OK):**
```json
[
  {
    "agency": "Agency 1",
    "bags_25kg": 600,
    "bags_50kg": 400
  },
  {
    "agency": "Agency 2",
    "bags_25kg": 350,
    "bags_50kg": 200
  }
]
```

### Bags by Fertilizer
**GET** `/admin/analytics/bags-by-fertilizer`

Get total bags distributed per fertilizer type, broken down by bag size.

**Response (200 OK):**
```json
[
  {
    "fertilizer": "NPK 15-15-15",
    "bags_25kg": 500,
    "bags_50kg": 300
  },
  {
    "fertilizer": "Urea",
    "bags_25kg": 450,
    "bags_50kg": 300
  }
]
```

### Agency Distribution by District
**GET** `/admin/analytics/agency-district-distribution`

Get detailed distribution of fertilizers (by size) distributed by a specific agency in a specific district, broken down by chiefdom and fertilizer type.

**Query Parameters:**
- `agency_id` (required): The ID of the agency
- `district_id` (required): The ID of the district

**Example Request:**
```
GET /api/admin/analytics/agency-district-distribution?agency_id=1&district_id=2
```

**Response (200 OK):**
```json
{
  "agency": {
    "id": 1,
    "name": "Agency 1"
  },
  "district": {
    "id": 2,
    "name": "District 2"
  },
  "distributions": [
    {
      "fertilizer": "NPK 15-15-15",
      "chiefdom": "Chiefdom A",
      "bags_25kg": 50,
      "bags_50kg": 30
    },
    {
      "fertilizer": "NPK 15-15-15",
      "chiefdom": "Chiefdom B",
      "bags_25kg": 40,
      "bags_50kg": 20
    },
    {
      "fertilizer": "Urea",
      "chiefdom": "Chiefdom A",
      "bags_25kg": 60,
      "bags_50kg": 25
    }
  ],
  "totals": {
    "total_bags_25kg": 150,
    "total_bags_50kg": 75
  }
}
```

**Response (400 Bad Request):**
```json
{
  "error": "agency_id and district_id parameters are required"
}
```

**Response (404 Not Found):**
```json
{
  "error": "Agency not found"
}
```

**Response (403 Forbidden - Non-Admin):**
```json
{
  "error": "Forbidden"
}
```

---

## Error Responses

### 400 Bad Request
```json
{
  "errors": ["Field validation error message"]
}
```

### 401 Unauthorized
```json
{
  "error": "Unauthorized"
}
```

### 403 Forbidden
```json
{
  "error": "User not associated with any agency"
}
```

### 404 Not Found
```json
{
  "error": "Agency not found"
}
```

### 429 Too Many Requests
```json
{
  "error": "Too many requests. Please try again later."
}
```

### 500 Internal Server Error
```json
{
  "error": "Failed to create submission",
  "details": "Error message here"
}
```

---

### User Roles

- **admin**: Full access to all endpoints and data
- **agency**: Limited to their own agency data and submissions

---

## Administrative Reference Data CRUD (Admin Only)

These endpoints provide full CRUD operations for reference data.

### Regions Management
**GET/POST** `/admin/regions`
**GET/PUT/DELETE** `/admin/regions/:id`

**Request (Post):**
```json
{ "name": "Northern Region" }
```

### Districts Management
**GET/POST** `/admin/districts`
**GET/PUT/DELETE** `/admin/districts/:id`

**Request (Post):**
```json
{ "name": "Bombali District", "region_id": 1 }
```

### Chiefdoms Management
**GET/POST** `/admin/chiefdoms`
**GET/PUT/DELETE** `/admin/chiefdoms/:id`

**Request (Post):**
```json
{ "name": "Binkolo Chiefdom", "district_id": 1 }
```

### Townships Management
**GET/POST** `/admin/townships`
**GET/PUT/DELETE** `/admin/townships/:id`

**Request (Post):**
```json
{ "name": "Central 1", "chiefdom_id": 1 }
```

### Dealers Management
**GET/POST** `/admin/dealers`
**GET/PUT/DELETE** `/admin/dealers/:id`

**Request (Post/Put) with nested contacts and outlets:**
```json
{
  "dealer": {
    "name": "Test Dealer Corp",
    "status": "active",
    "category": "Fertilizer Dealer",
    "category_type": "Wholesaler",
    "head_office_address": "123 Main St",
    "ceo_name": "John Doe",
    "registration_date": "2026-01-01",
    "license_expiry_date": "2027-01-01",
    "licensing_status": "Active",
    "contact_people_attributes": [
      { "name": "Jane Smith", "role": "Sales Manager", "phone": "123456", "email": "jane@example.com", "is_primary": true }
    ],
    "outlets_attributes": [
      { "address": "Terminal 1", "region_id": 1, "district_id": 1, "chiefdom_id": 1, "township_id": 1 }
    ]
  }
}
```

---

## Reference Data Endpoints (Public/Auth)

### Get Regions
**GET** `/regions`
Returns all regions.

### Get Townships
**GET** `/townships`
Returns all townships.

---

## Analytics Endpoints (Admin Only)

### Bags by District
**GET** `/admin/analytics/bags-by-district`

### Bags by Agency
**GET** `/admin/analytics/bags-by-agency`

### Bags by Fertilizer
**GET** `/admin/analytics/bags-by-fertilizer`

### Agency Distribution by District
**GET** `/admin/analytics/agency-district-distribution?agency_id=1&district_id=2`

### Dealers by Region
**GET** `/admin/analytics/dealers-by-region`
Get total number of unique dealers per region.

### Dealers by District
**GET** `/admin/analytics/dealers-by-district`
Get total number of unique dealers per district.

### Dealers by Category
**GET** `/admin/analytics/dealers-by-category`
Get breakdown of dealers by their category.

### License Status Summary
**GET** `/admin/analytics/license-status-summary`
Get counts of Active vs Expired/Unlicensed dealers.

### Dealer Operational Coverage
**GET** `/admin/analytics/dealer-operational-coverage`
Get detailed list of dealers, their outlet counts, and the regions/districts they operate in.

---

## Database Schema

### Users
- id, name, email, password_digest, role, created_at, updated_at

### Agencies
- id, name, project_name, ministry, user_id (foreign key), created_at, updated_at

### Regions
- id, name, created_at, updated_at

### Districts
- id, name, region_id (foreign key, optional), created_at, updated_at

### Chiefdoms
- id, name, district_id (foreign key), created_at, updated_at

### Townships
- id, name, chiefdom_id (foreign key), created_at, updated_at

### Dealers
- id, name, license_number, status, category, category_type, head_office_address, ceo_name, registration_date, license_expiry_date, licensing_status, created_at, updated_at

### ContactPeople
- id, dealer_id (foreign key), name, phone, email, role, is_primary, created_at, updated_at

### Outlets
- id, dealer_id (foreign key), address, region_id, district_id, chiefdom_id, township_id, created_at, updated_at

### Submissions
- id, agency_id, submitted_by_id, draft_id (optional), submitted_at, created_at, updated_at

### SubmissionItems
- id, submission_id, district_id, chiefdom_id, fertilizer_id, dealer_id, bags_25kg, bags_50kg, created_at, updated_at

---

## Installation & Setup

1. Install dependencies:
   ```bash
   bundle install
   ```

2. Set up the database:
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

3. Start the server:
   ```bash
   rails server -p 3000
   ```

---

## Environment Configuration

Set these environment variables in `.env` file:

```
FRONTEND_DOMAIN=http://localhost:3000
DATABASE_URL=postgresql://user:password@localhost/nafra_backend
```
