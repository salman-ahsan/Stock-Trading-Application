# 📈 Stock Trading Application

A comprehensive **three-tier web application** for simulated stock trading with a **normalized relational MySQL database**, demonstrating professional DBMS design, REST API architecture, and full-stack development practices.

**🎓 Academic Project:** Database Management Systems (DBMS) Course - Bahria University BSCS

---

## 🎯 Project Overview

Stock Trading Application is a practical DBMS project that allows users to simulate buying and selling stocks, manage portfolios in real-time, and track their trading performance. The system demonstrates advanced database concepts including **3NF normalization, ACID transactions, triggers, views, and parameterized queries**.

### Key Highlights
- ✅ **7 Normalized Tables** following Third Normal Form (3NF)
- ✅ **3 Database Triggers** for automatic balance, portfolio, and P&L updates
- ✅ **2 SQL Views** for portfolio summary and market statistics
- ✅ **13 REST API Endpoints** with complete CRUD operations
- ✅ **Real-time Stock Prices** updating every 3 seconds
- ✅ **ACID Compliance** for all transactions
- ✅ **SHA-256 Password Hashing** and secure authentication
- ✅ **Admin Dashboard** with user management and statistics

---

## 🏗️ Architecture

### Three-Tier System Design
```
Frontend (HTML5/CSS3/JavaScript) 
    ↓ HTTP/REST
Backend (Node.js/Express.js)
    ↓ SQL Queries
Database (MySQL 8.0)
```

---

## 📊 Database Schema

**7 Tables:** users • stocks • orders • transactions • portfolio • watchlist • admin

| Table | Purpose |
|-------|---------|
| **users** | Authentication, profiles, balance, eco_score |
| **stocks** | Stock data, symbols, current prices |
| **orders** | Buy/Sell orders with status tracking |
| **transactions** | Completed trades with P&L |
| **portfolio** | User stock holdings |
| **watchlist** | Tracked stocks |
| **admin** | System administrators |

**Features:** 3NF Normalization • ACID Transactions • 3 Triggers • 2 Views • Foreign Key Constraints

---

## ✨ Core Features

### User Management
- User registration & secure login
- SHA-256 password hashing
- Profile management
- Role-based access (User/Admin)

### Stock Trading
- Browse 20 stocks with real-time prices
- Buy/Sell with automatic validation
- Real-time P&L calculation
- Balance verification

### Portfolio Management
- Real-time portfolio tracking
- Unrealized gain/loss calculations
- Automatic database trigger updates
- Transaction history

### Advanced Features
- Watchlist management
- Admin dashboard with statistics
- Eco impact calculation
- Aggregate market queries

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | HTML5, CSS3, Vanilla JavaScript |
| **Backend** | Node.js, Express.js |
| **Database** | MySQL 8.0, MySQL2 Driver |
| **Security** | SHA-256 Hashing, Parameterized Queries |
| **Tools** | Git, Postman, MySQL Workbench |

---

## 📁 Project Structure

```
Stock-Trading-Application/
├── README.md                              # Project documentation
├── SETUP_GUIDE.md                         # Setup instructions
├── API_DOCUMENTATION.md                   # API reference
├── CONTRIBUTING.md                        # Contributing guidelines
├── package.json                           # Dependencies
├── server.js                              # Backend API
├── index1.html                            # Frontend
├── COMPLETE_DATABASE_SETUP.sql            # Database
└── Stock_Trading_Database_Presentation.pptx
```

---

## 🚀 Quick Start

### Prerequisites
- Node.js v14+
- MySQL 8.0+
- Git

### Installation

1. **Clone Repository**
```bash
git clone https://github.com/salman-ahsan/Stock-Trading-Application.git
cd Stock-Trading-Application
```

2. **Install Dependencies**
```bash
npm install
```

3. **Setup Database**
```bash
mysql -u root -p < COMPLETE_DATABASE_SETUP.sql
```

4. **Configure Database** (in server.js)
```javascript
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'your_password',
    database: 'stock_trading_db'
});
```

5. **Start Backend**
```bash
npm start
```
Server: `http://localhost:3000`

6. **Open Frontend**
```bash
# Open index1.html in browser
```

---

## 📚 API Endpoints (13 Total)

### Authentication
- `POST /api/user/login` - User login
- `POST /api/user/register` - User registration

### Stocks
- `GET /api/stocks` - Get all stocks
- `GET /api/stocks/:id` - Get stock details

### Trading
- `POST /api/orders/buy` - Create buy order
- `POST /api/orders/sell` - Create sell order
- `GET /api/orders/:userId` - Get user orders

### Portfolio
- `GET /api/portfolio/:userId` - Get portfolio
- `GET /api/transactions/:userId` - Get transaction history

### Admin
- `GET /api/admin/users` - Get all users
- `GET /api/admin/statistics` - Get statistics
- `GET /api/dashboard` - Dashboard data

---

## 🔐 Security Implementation

- ✅ SHA-256 Password Hashing
- ✅ Parameterized SQL Queries (SQL Injection Prevention)
- ✅ Input Validation at API Layer
- ✅ CORS Configuration
- ✅ Session-Based Authentication
- ✅ Role-Based Access Control
- ✅ Foreign Key Constraints

---

## 💡 DBMS Concepts Demonstrated

1. **Normalization:** 3NF design eliminating anomalies
2. **Transactions:** ACID-compliant trading operations
3. **Triggers:** 3 automatic database triggers
4. **Views:** 2 SQL views for aggregation
5. **Constraints:** PK, FK, UNIQUE, CHECK constraints
6. **Indexes:** Performance optimization
7. **Relationships:** 1:N cardinality with cascades

---

## 👥 Team

| Name | Roll No | Role |
|------|---------|------|
| Salman Ahsan | 041 | Backend & Project Lead |
| Umer Zahoor | 033 | Database Design |
| Muhammad Talha | 030 | Frontend & Documentation |

---

## 🧪 Test Credentials

**Regular User:**
- Username: `salman_ahsan`
- Password: `password123`

**Admin User:**
- Username: `admin_main`
- Password: `admin_pass1`

---

## 📊 Sample Data Included

✅ 5 test user accounts  
✅ 20 sample stocks  
✅ Pre-populated orders and transactions  
✅ Sample watchlists and portfolios  

---

## 🎓 Learning Outcomes

This project demonstrates:
- Database Design & Normalization
- DBMS Concepts (Triggers, Views, Transactions)
- REST API Development
- Full-Stack Web Development
- Security Best Practices
- Git Version Control

---

## 📈 Performance

| Metric | Target |
|--------|--------|
| Page Load | < 3s |
| API Response | < 500ms |
| Database Query | < 200ms |
| Concurrent Users | 50+ |

---

## 🐛 Future Improvements

- Integration with live stock market API
- Mobile application (React Native)
- Cloud deployment (AWS/Heroku)
- Advanced analytics dashboard
- Email notifications
- Social trading features

---

## 📄 License

Educational project for DBMS course at Bahria University.

---

## 📧 Contact

**Repository:** https://github.com/salman-ahsan/Stock-Trading-Application.git

**Questions?** Open an issue on GitHub

---

## 🎉 Project Summary

A production-ready DBMS project suitable for **internship resumes**, **portfolio**, and **academic evaluation** demonstrating professional database design, full-stack development, and advanced SQL concepts.

**Built with ❤️ for learning and professional growth!**

---

*Last Updated: 25 May 2026*  
*Version: 2.0*
