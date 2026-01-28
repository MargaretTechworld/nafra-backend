# NAFRA Backend API Test Script
# This script demonstrates the complete setup and usage workflow

# Configuration
$BASE_URL = "http://localhost:3000/api"
$CONTENT_TYPE = "application/json"

Write-Host "=== NAFRA Backend API Test ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Admin Setup
Write-Host "Step 1: Create Admin User" -ForegroundColor Yellow
$adminBody = @{
    name = "System Admin"
    email = "admin@nafra.com"
    password = "AdminPass123!"
    password_confirmation = "AdminPass123!"
} | ConvertTo-Json

$adminResponse = Invoke-WebRequest -Uri "$BASE_URL/auth/admin-setup" `
    -Method POST `
    -Headers @{"Content-Type" = $CONTENT_TYPE} `
    -Body $adminBody

$admin = $adminResponse.Content | ConvertFrom-Json
$adminToken = $admin.token

Write-Host "✓ Admin created successfully" -ForegroundColor Green
Write-Host "  User ID: $($admin.user_id)"
Write-Host "  Email: $($admin.email)"
Write-Host "  Token: $($adminToken.Substring(0, 20))..." -ForegroundColor Gray
Write-Host ""

# Step 2: Create Agency
Write-Host "Step 2: Create Agency with User" -ForegroundColor Yellow
$agencyBody = @{
    name = "John Doe"
    agency_name = "Northern District Agency"
    ministry = "Ministry of Agriculture"
} | ConvertTo-Json

$agencyResponse = Invoke-WebRequest -Uri "$BASE_URL/auth/agency-setup" `
    -Method POST `
    -Headers @{
        "Content-Type" = $CONTENT_TYPE
        "Authorization" = "Bearer $adminToken"
    } `
    -Body $agencyBody

$agencyData = $agencyResponse.Content | ConvertFrom-Json
$agencyUser = $agencyData.user
$agency = $agencyData.agency

Write-Host "✓ Agency and user created successfully" -ForegroundColor Green
Write-Host "  User ID: $($agencyUser.user_id)"
Write-Host "  User Email: $($agencyUser.email)"
Write-Host "  User Password: $($agencyUser.password)" -ForegroundColor Yellow
Write-Host "  Agency ID: $($agency.agency_id)"
Write-Host "  Agency Name: $($agency.name)"
Write-Host ""

# Step 3: Agency User Login
Write-Host "Step 3: Agency User Login" -ForegroundColor Yellow
$loginBody = @{
    email = $agencyUser.email
    password = $agencyUser.password
} | ConvertTo-Json

$loginResponse = Invoke-WebRequest -Uri "$BASE_URL/auth/login" `
    -Method POST `
    -Headers @{"Content-Type" = $CONTENT_TYPE} `
    -Body $loginBody

$loginData = $loginResponse.Content | ConvertFrom-Json
$agencyToken = $loginData.token

Write-Host "✓ Agency user logged in successfully" -ForegroundColor Green
Write-Host "  Role: $($loginData.role)"
Write-Host "  Token: $($agencyToken.Substring(0, 20))..." -ForegroundColor Gray
Write-Host ""

# Step 4: Admin Login
Write-Host "Step 4: Admin Login (Alternative)" -ForegroundColor Yellow
$adminLoginBody = @{
    email = "admin@nafra.com"
    password = "AdminPass123!"
} | ConvertTo-Json

$adminLoginResponse = Invoke-WebRequest -Uri "$BASE_URL/auth/login" `
    -Method POST `
    -Headers @{"Content-Type" = $CONTENT_TYPE} `
    -Body $adminLoginBody

$adminLoginData = $adminLoginResponse.Content | ConvertFrom-Json

Write-Host "✓ Admin logged in successfully" -ForegroundColor Green
Write-Host "  Role: $($adminLoginData.role)"
Write-Host ""

Write-Host "=== All Tests Passed ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "You can now use the tokens to test other endpoints:" -ForegroundColor Gray
Write-Host "  Admin Token:  $($adminLoginData.token.Substring(0, 20))..." -ForegroundColor Gray
Write-Host "  Agency Token: $($agencyToken.Substring(0, 20))..." -ForegroundColor Gray
