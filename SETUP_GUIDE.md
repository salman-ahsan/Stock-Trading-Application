# 🚀 Complete Setup Guide - Stock Trading Application

This guide will walk you through setting up the entire Stock Trading Application from scratch.

## Prerequisites Checklist

Before starting, ensure you have:
- [ ] Node.js (v14 or higher) - Download from https://nodejs.org
- [ ] MySQL Server (v8.0 or compatible) - Download from https://dev.mysql.com/downloads/mysql/
- [ ] Git - Download from https://git-scm.com
- [ ] A code editor (VS Code recommended)

---

## Step-by-Step Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/salman-ahsan/Stock-Trading-Application.git
cd Stock-Trading-Application
```

### Step 2: Install Node.js Dependencies

```bash
npm install
```

Verify installation:
```bash
npm list
```

### Step 3: MySQL Database Setup

#### Option A: Using Command Line (Recommended)

```bash
mysql -u root -p < COMPLETE_DATABASE_SETUP.sql
```

#### Option B: Using MySQL Workbench

1. Open MySQL Workbench
2. Open file `COMPLETE_DATABASE_SETUP.sql`
3. Execute all scripts

#### Option C: Using phpMyAdmin

1. Go to http://localhost/phpmyadmin
2. Click "Import" tab
3. Select `COMPLETE_DATABASE_SETUP.sql`
4. Click "Go"

### Step 4: Verify Database Setup

```sql
USE stock_trading_db;
SHOW TABLES;
```

Expected output:
```
users
stocks
orders
transactions
portfolio
watchlist
admin
```

### Step 5: Configure Backend Connection

Edit `server.js` and update:

```javascript
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'stock_trading_db'
});
```

### Step 6: Start the Backend Server

```bash
npm start
```

Expected output:
```
✅ Connected to MySQL (stock_trading_db)
Server running on port 3000
```

### Step 7: Open the Frontend

Open `index1.html` in your browser or use:

```bash
npx http-server
```

Then open: `http://localhost:8080`

---

## 🧪 Testing the Application

### Test Login

**Regular User:**
- Username: `salman_ahsan`
- Password: `password123`

**Admin User:**
- Username: `admin_main`
- Password: `admin_pass1`

---

## 🔧 Troubleshooting

### Port Already in Use

```bash
netstat -ano | findstr :3000
taskkill /PID [PID] /F
```

### Database Connection Failed

1. Ensure MySQL is running
2. Check credentials in server.js
3. Verify database exists: `USE stock_trading_db;`

### Module Not Found

```bash
rm -rf node_modules package-lock.json
npm install
```

---

## ✅ Verification Checklist

After setup, verify:

- [ ] Node.js dependencies installed
- [ ] MySQL database created
- [ ] Backend server starts without errors
- [ ] Frontend loads in browser
- [ ] Can login with test credentials
- [ ] Can browse stocks
- [ ] Can perform trading operations
- [ ] Dashboard shows data

---

## 🎉 You're Ready!

If you've completed all steps, your Stock Trading Application is ready to use!

