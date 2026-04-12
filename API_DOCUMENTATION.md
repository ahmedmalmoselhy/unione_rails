# UniOne API Documentation

## Base URL
```
http://localhost:3000/api
```

## Authentication
All authenticated endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer <token>
```

---

## Authentication Endpoints

### POST /api/auth/register
Create a new user account.

**Request Body:**
```json
{
  "user": {
    "email": "user@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "first_name": "John",
    "last_name": "Doe"
  }
}
```

**Response:** `201 Created`

---

### POST /api/auth/login
Authenticate user and receive token.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": { "id": 1, "email": "user@example.com", ... },
    "token": "eyJhbGciOiJIUzI1NiJ9..."
  }
}
```

---

### GET /api/auth/me
Get current authenticated user profile.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`

---

### DELETE /api/auth/logout
Logout and revoke token.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`

---

## Student Portal Endpoints

### GET /api/student/profile
Get student profile information.

**Headers:** `Authorization: Bearer <token>` (Student role required)

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "student": {
      "id": 1,
      "student_number": "STU2020001",
      "user": { "first_name": "John", "last_name": "Doe", ... },
      "faculty": { "name": "Engineering", "code": "ENG" },
      "department": { "name": "Computer Engineering", "code": "CE" },
      "academic_year": 4,
      "semester": 1,
      "gpa": 3.75,
      "academic_standing": "excellent"
    }
  }
}
```

---

### GET /api/student/enrollments
List all student enrollments.

**Query Parameters:**
- `status` - Filter by status (active, completed, dropped)
- `term_id` - Filter by academic term

**Response:** `200 OK`

---

### POST /api/student/enrollments
Enroll in a course section.

**Request Body:**
```json
{
  "section_id": 1,
  "academic_term_id": 2
}
```

**Response:** `201 Created`

---

### DELETE /api/student/enrollments/:id
Drop a course enrollment.

**Response:** `200 OK`

---

### GET /api/student/grades
Get all grades and GPA information.

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "grades": [
      {
        "course": { "code": "CS201", "name": "Data Structures", "credit_hours": 3 },
        "term": "Spring 2025",
        "points": 85,
        "letter_grade": "A"
      }
    ],
    "cumulative_gpa": 3.75,
    "credit_hours_completed": 120
  }
}
```

---

### GET /api/student/transcript
Get academic transcript data.

**Response:** `200 OK`

---

### GET /api/student/transcript/pdf
Download academic transcript as PDF.

**Response:** `200 OK` (PDF file)

---

### GET /api/student/schedule
Get class schedule.

**Response:** `200 OK`

---

### GET /api/student/schedule/ics
Download schedule as iCal file.

**Response:** `200 OK` (ICS file)

---

### GET /api/student/attendance
Get attendance records and statistics.

**Response:** `200 OK`

---

### GET /api/student/ratings
Get submitted course ratings.

**Response:** `200 OK`

---

### POST /api/student/ratings
Submit a course rating.

**Request Body:**
```json
{
  "enrollment_id": 1,
  "rating": 5,
  "feedback": "Great course!"
}
```

**Response:** `201 Created`

---

### GET /api/student/waitlist
Get waitlist entries.

**Response:** `200 OK`

---

### POST /api/student/waitlist
Add to section waitlist.

**Request Body:**
```json
{
  "section_id": 1,
  "academic_term_id": 2
}
```

**Response:** `201 Created`

---

### DELETE /api/student/waitlist/:section_id
Remove from waitlist.

**Response:** `200 OK`

---

## Professor Portal Endpoints

### GET /api/professor/profile
Get professor profile information.

**Response:** `200 OK`

---

### GET /api/professor/sections
List taught sections.

**Response:** `200 OK`

---

### GET /api/professor/sections/:id/students
Get students in a section.

**Response:** `200 OK`

---

### GET /api/professor/sections/:section_id/grades
Get all grades for a section.

**Response:** `200 OK`

---

### POST /api/professor/sections/:section_id/grades
Submit grades for a section.

**Request Body:**
```json
{
  "grades": [
    {
      "enrollment_id": 1,
      "points": 85,
      "letter_grade": "A"
    }
  ]
}
```

**Response:** `200 OK`

---

### GET /api/professor/sections/:section_id/attendance
Get attendance sessions.

**Response:** `200 OK`

---

### POST /api/professor/sections/:section_id/attendance
Create attendance session.

**Response:** `201 Created`

---

### PUT /api/professor/sections/:section_id/attendance/:session_id
Update attendance records.

**Response:** `200 OK`

---

### GET /api/professor/sections/:section_id/announcements
Get section announcements.

**Response:** `200 OK`

---

### POST /api/professor/sections/:section_id/announcements
Create section announcement.

**Response:** `201 Created`

---

### DELETE /api/professor/sections/:section_id/announcements/:id
Delete announcement.

**Response:** `200 OK`

---

## Admin Endpoints

### GET /api/admin/dashboard
Get analytics dashboard data.

**Headers:** Admin role required

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "overview": {
      "total_students": 1500,
      "active_students": 1450,
      "total_professors": 85,
      "total_courses": 250
    },
    "recent_activity": { ... },
    "enrollment_trends": { ... },
    "academic_performance": { ... }
  }
}
```

---

### GET /api/admin/users
List all users with filtering.

**Query Parameters:**
- `role` - Filter by role slug
- `active` - Filter by active status (true/false)
- `search` - Search by name or email
- `page` - Page number
- `per_page` - Items per page

**Response:** `200 OK`

---

### POST /api/admin/users
Create new user.

**Response:** `201 Created`

---

### PATCH /api/admin/users/:id
Update user.

**Response:** `200 OK`

---

### POST /api/admin/users/:id/assign_role
Assign role to user.

**Request Body:**
```json
{
  "role_slug": "student"
}
```

**Response:** `200 OK`

---

### POST /api/admin/users/:id/activate
Activate user account.

**Response:** `200 OK`

---

### POST /api/admin/users/:id/deactivate
Deactivate user account.

**Response:** `200 OK`

---

### GET /api/admin/users/statistics
Get user statistics.

**Response:** `200 OK`

---

### GET /api/admin/universities
List universities.

**Response:** `200 OK`

---

### GET /api/admin/terms/current
Get current active academic term.

**Response:** `200 OK`

---

### POST /api/admin/terms/:id/activate
Activate academic term.

**Response:** `200 OK`

---

### GET /api/admin/audit_logs
List audit logs with filtering.

**Query Parameters:**
- `user_id` - Filter by user
- `action_type` - Filter by action (create, update, destroy)
- `auditable_type` - Filter by model type
- `start_date` / `end_date` - Date range filter

**Response:** `200 OK`

---

### GET /api/admin/audit_logs/statistics
Get audit log statistics.

**Response:** `200 OK`

---

## Shared Endpoints

### GET /api/announcements
Get all announcements.

**Response:** `200 OK`

---

### POST /api/announcements/:id/read
Mark announcement as read.

**Response:** `200 OK`

---

### GET /api/notifications
Get user notifications.

**Query Parameters:**
- `unread` - Filter unread only (true/false)

**Response:** `200 OK`

---

### POST /api/notifications/read-all
Mark all notifications as read.

**Response:** `200 OK`

---

## Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "error": "Invalid request parameters",
  "errors": ["email is required"]
}
```

### 401 Unauthorized
```json
{
  "error": "Unauthorized. Please log in."
}
```

### 403 Forbidden
```json
{
  "error": "You don't have permission to access this resource."
}
```

### 404 Not Found
```json
{
  "error": "Resource not found."
}
```

### 422 Unprocessable Entity
```json
{
  "success": false,
  "errors": ["Validation error message"]
}
```

---

## Rate Limiting

API endpoints are rate-limited:
- Login: 20 requests per minute per IP
- Password reset: 10 requests per hour per IP
- General API: 1000 requests per hour per authenticated user

---

## Pagination

List endpoints support pagination using Kaminari:

**Query Parameters:**
- `page` - Page number (default: 1)
- `per_page` - Items per page (default: 20, max: 100)

**Response Meta:**
```json
{
  "meta": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 100,
    "per_page": 20
  }
}
```
