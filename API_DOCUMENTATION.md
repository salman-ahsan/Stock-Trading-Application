# 📚 API Documentation - Stock Trading Application

Complete REST API documentation with examples for all 13 endpoints.

**Base URL:** `http://localhost:3000/api`

---

## 🔐 Authentication Endpoints

### 1. User Registration
**POST** `/user/register`

**Request:**
```json
{
  "username": "salman_ahsan",
  "email": "salman@example.com",
  "password": "password123",
  "full_name": "Salman Ahsan"
}
```

**Response:**
```json
{
  "success": true,
  "user_id": 1,
  "message": "User registered successfully"
}
```

---

### 2. User Login
**POST** `/user/login`

**Request:**
```json
{
  "username": "salman_ahsan",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "user_id": 1,
  "username": "salman_ahsan",
  "balance": 100000,
  "message": "Login successful"
}
```

---

## 📊 Stock Endpoints

### 3. Get All Stocks
**GET** `/stocks`

**Response:**
```json
{
  "success": true,
  "count": 20,
  "stocks": [
    {
      "stock_id": 1,
      "symbol": "AAPL",
      "company_name": "Apple Inc.",
      "current_price": 175.50,
      "base_price": 150.00
    }
  ]
}
```

---

### 4. Get Stock Details
**GET** `/stocks/:stock_id`

**Response:**
```json
{
  "success": true,
  "stock": {
    "stock_id": 1,
    "symbol": "AAPL",
    "company_name": "Apple Inc.",
    "current_price": 175.50,
    "base_price": 150.00,
    "change_percent": 17.0
  }
}
```

---

## 💰 Trading Endpoints

### 5. Create Buy Order
**POST** `/orders/buy`

**Request:**
```json
{
  "user_id": 1,
  "stock_id": 1,
  "quantity": 10,
  "price": 175.50
}
```

**Response:**
```json
{
  "success": true,
  "order_id": 1,
  "status": "COMPLETED",
  "message": "Buy order executed successfully",
  "details": {
    "stock_symbol": "AAPL",
    "quantity": 10,
    "price_per_share": 175.50,
    "total_amount": 1755.00,
    "new_balance": 98245.00
  }
}
```

---

### 6. Create Sell Order
**POST** `/orders/sell`

**Request:**
```json
{
  "user_id": 1,
  "stock_id": 1,
  "quantity": 5,
  "price": 180.00
}
```

**Response:**
```json
{
  "success": true,
  "order_id": 2,
  "status": "COMPLETED",
  "message": "Sell order executed successfully",
  "details": {
    "stock_symbol": "AAPL",
    "quantity": 5,
    "price_per_share": 180.00,
    "total_amount": 900.00,
    "pnl": 22.50,
    "pnl_percent": 2.56,
    "new_balance": 99145.00
  }
}
```

---

### 7. Get User Orders
**GET** `/orders/:user_id`

**Response:**
```json
{
  "success": true,
  "count": 2,
  "orders": [
    {
      "order_id": 1,
      "stock_symbol": "AAPL",
      "type": "BUY",
      "quantity": 10,
      "price": 175.50,
      "status": "COMPLETED",
      "created_at": "2026-05-25 10:30:45"
    }
  ]
}
```

---

## 📈 Portfolio Endpoints

### 8. Get User Portfolio
**GET** `/portfolio/:user_id`

**Response:**
```json
{
  "success": true,
  "portfolio": {
    "user_id": 1,
    "total_value": 2350.50,
    "total_invested": 2275.00,
    "unrealized_pnl": 75.50,
    "unrealized_pnl_percent": 3.32,
    "holdings": [
      {
        "stock_symbol": "AAPL",
        "quantity": 5,
        "avg_buy_price": 170.00,
        "current_price": 175.50,
        "current_value": 877.50
      }
    ]
  }
}
```

---

### 9. Get Transaction History
**GET** `/transactions/:user_id`

**Response:**
```json
{
  "success": true,
  "count": 2,
  "transactions": [
    {
      "transaction_id": 1,
      "stock_symbol": "AAPL",
      "type": "BUY",
      "quantity": 10,
      "price_per_share": 175.50,
      "total_amount": 1755.00,
      "transaction_date": "2026-05-25 10:30:45"
    }
  ]
}
```

---

## 👤 User Profile Endpoints

### 10. Get User Profile
**GET** `/user/profile/:user_id`

**Response:**
```json
{
  "success": true,
  "profile": {
    "user_id": 1,
    "username": "salman_ahsan",
    "email": "salman@example.com",
    "full_name": "Salman Ahsan",
    "balance": 99145.00,
    "eco_score": 10,
    "total_trades": 2,
    "created_at": "2026-05-20 08:15:30"
  }
}
```

---

### 11. Update User Profile
**PUT** `/user/profile/:user_id`

**Request:**
```json
{
  "full_name": "Salman Ahsan Updated",
  "email": "newemail@example.com"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Profile updated successfully"
}
```

---

## 📊 Admin Endpoints

### 12. Get All Users (Admin Only)
**GET** `/admin/users`

**Response:**
```json
{
  "success": true,
  "count": 5,
  "users": [...]
}
```

---

### 13. Get System Statistics (Admin Only)
**GET** `/admin/statistics`

**Response:**
```json
{
  "success": true,
  "statistics": {
    "total_users": 5,
    "total_trades": 52,
    "total_volume": 1250,
    "top_trader": {...}
  }
}
```

---

## ❌ Common Error Responses

### 400 Bad Request
```json
{
  "error": "Invalid request parameters"
}
```

### 401 Unauthorized
```json
{
  "error": "Invalid username or password"
}
```

### 404 Not Found
```json
{
  "error": "User not found"
}
```

### 500 Server Error
```json
{
  "error": "Database connection failed"
}
```

---

**API Version:** 2.0  
**Last Updated:** 25 May 2026
