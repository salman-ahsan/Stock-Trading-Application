const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bodyParser = require('body-parser');
const crypto = require('crypto');

const app = express();
app.use(cors());
app.use(bodyParser.json());

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'stock_trading_db'
});

db.connect(err => {
    if (err) {
        console.error('❌ Database connection failed:', err.message);
        process.exit(1);
    }
    console.log('✅ Connected to MySQL (stock_trading_db)');
});

function verifyPassword(pwd, hash) {
    if (pwd === hash) return true;
    return crypto.createHash('sha256').update(pwd).digest('hex') === hash;
}

// ============================================================
//  USER LOGIN & REGISTER
// ============================================================

app.post('/api/user/login', (req, res) => {
    const { username, password } = req.body;
    if (!username || !password) {
        return res.status(400).json({ error: 'Username and password required' });
    }

    db.query("SELECT user_id, username, password_hash, email, balance FROM users WHERE username = ?", [username], (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        if (results.length === 0) return res.status(401).json({ error: 'Invalid username' });

        const user = results[0];
        if (!verifyPassword(password, user.password_hash)) {
            return res.status(401).json({ error: 'Invalid password' });
        }

        db.query("UPDATE users SET last_active = NOW() WHERE user_id = ?", [user.user_id]);

        res.json({ 
            success: true, 
            user: { 
                user_id: user.user_id, 
                username: user.username, 
                email: user.email, 
                balance: user.balance 
            } 
        });
    });
});

app.post('/api/user/register', (req, res) => {
    const { username, email, password, balance } = req.body;
    if (!username || !email || !password) {
        return res.status(400).json({ error: 'All fields required' });
    }

    const hash = crypto.createHash('sha256').update(password).digest('hex');
    const sql = "INSERT INTO users (username, email, password_hash, balance, last_active) VALUES (?, ?, ?, ?, NOW())";
    
    db.query(sql, [username, email, hash, balance || 10000], (err, result) => {
        if (err) {
            if (err.code === 'ER_DUP_ENTRY') {
                return res.status(400).json({ error: 'Username or email already exists' });
            }
            return res.status(400).json({ error: 'Registration failed' });
        }
        res.json({ success: true, user_id: result.insertId });
    });
});

app.post('/api/user/update-last-active/:userId', (req, res) => {
    db.query("UPDATE users SET last_active = NOW() WHERE user_id = ?", [req.params.userId], (err) => {
        if (err) return res.status(500).json({ error: 'Update failed' });
        res.json({ success: true });
    });
});

// ============================================================
//  ADMIN LOGIN
// ============================================================

app.post('/api/admin/login', (req, res) => {
    const { username, password } = req.body;
    if (!username || !password) {
        return res.status(400).json({ error: 'Credentials required' });
    }

    db.query("SELECT admin_id, username, password_hash, role FROM admin WHERE username = ?", [username], (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        if (results.length === 0) return res.status(401).json({ error: 'Invalid admin username' });

        const admin = results[0];
        if (!verifyPassword(password, admin.password_hash)) {
            return res.status(401).json({ error: 'Invalid password' });
        }

        res.json({ 
            success: true, 
            admin: { 
                admin_id: admin.admin_id, 
                username: admin.username, 
                role: admin.role 
            } 
        });
    });
});

// ============================================================
//  STOCKS
// ============================================================

app.get('/api/stocks', (req, res) => {
    db.query("SELECT * FROM stocks ORDER BY symbol", (err, results) => {
        if (err) return res.status(500).json({ error: 'Query failed' });
        res.json(results || []);
    });
});

// ============================================================
//  USER DATA
// ============================================================

app.get('/api/user/:id', (req, res) => {
    db.query("SELECT user_id, username, email, balance FROM users WHERE user_id = ?", [req.params.id], (err, results) => {
        if (err) return res.status(500).json({ error: 'Query failed' });
        res.json(results[0] || {});
    });
});

// ============================================================
//  PORTFOLIO (NO VIEW - DIRECT QUERY)
// ============================================================

app.get('/api/portfolio/:userId', (req, res) => {
    const query = `
        SELECT 
            p.portfolio_id,
            p.user_id,
            p.stock_id,
            s.symbol,
            s.company_name,
            p.quantity,
            p.avg_buy_price,
            s.current_price,
            (p.quantity * p.avg_buy_price) AS invested_value,
            (p.quantity * s.current_price) AS current_value,
            ((p.quantity * s.current_price) - (p.quantity * p.avg_buy_price)) AS profit_loss,
            CASE 
                WHEN (p.quantity * p.avg_buy_price) = 0 THEN 0
                ELSE (((p.quantity * s.current_price) - (p.quantity * p.avg_buy_price)) / (p.quantity * p.avg_buy_price)) * 100
            END AS profit_loss_pct
        FROM portfolio p
        JOIN stocks s ON p.stock_id = s.stock_id
        WHERE p.user_id = ?
        ORDER BY s.symbol ASC
    `;

    db.query(query, [req.params.userId], (err, results) => {
        if (err) {
            console.error('Portfolio query error:', err);
            return res.status(500).json({ error: 'Portfolio query failed' });
        }
        res.json(results || []);
    });
});

// ============================================================
//  WATCHLIST
// ============================================================

app.get('/api/watchlist/:userId', (req, res) => {
    db.query(`
        SELECT w.watchlist_id, w.added_at, s.stock_id, s.symbol, s.company_name, s.sector, s.current_price
        FROM watchlist w
        JOIN stocks s ON w.stock_id = s.stock_id
        WHERE w.user_id = ?
        ORDER BY s.symbol ASC
    `, [req.params.userId], (err, results) => {
        if (err) return res.status(500).json({ error: 'Watchlist query failed' });
        res.json(results || []);
    });
});

// ============================================================
//  TRANSACTIONS (NO VIEW - DIRECT QUERY)
// ============================================================

app.get('/api/transactions/:userId', (req, res) => {
    db.query(`
        SELECT t.transaction_id, t.transaction_date, o.order_type, s.symbol, s.company_name, t.quantity, t.price_per_share, t.total_amount
        FROM transactions t
        JOIN orders o ON t.order_id = o.order_id
        JOIN stocks s ON t.stock_id = s.stock_id
        WHERE t.user_id = ?
        ORDER BY t.transaction_date DESC
    `, [req.params.userId], (err, results) => {
        if (err) return res.status(500).json({ error: 'Transactions query failed' });
        res.json(results || []);
    });
});

// ============================================================
//  TOP STOCKS (NO VIEW - DIRECT QUERY)
// ============================================================

app.get('/api/top-stocks', (req, res) => {
    db.query(`
        SELECT 
            s.stock_id,
            s.symbol,
            s.company_name,
            COUNT(DISTINCT t.transaction_id) AS total_trades,
            COALESCE(SUM(t.quantity), 0) AS total_volume,
            COALESCE(SUM(t.total_amount), 0) AS total_value_traded
        FROM stocks s
        LEFT JOIN transactions t ON s.stock_id = t.stock_id
        GROUP BY s.stock_id, s.symbol, s.company_name
        ORDER BY total_volume DESC
        LIMIT 10
    `, (err, results) => {
        if (err) {
            console.error('Top stocks query error:', err);
            return res.status(500).json({ error: 'Top stocks query failed' });
        }
        res.json(results || []);
    });
});

// ============================================================
//  ADMIN USERS
// ============================================================

app.get('/api/admin/users', (req, res) => {
    db.query(`
        SELECT 
            u.user_id,
            u.username,
            u.email,
            u.balance,
            u.created_at,
            u.last_active,
            COUNT(DISTINCT t.transaction_id) AS total_transactions
        FROM users u
        LEFT JOIN transactions t ON u.user_id = t.user_id
        GROUP BY u.user_id, u.username, u.email, u.balance, u.created_at, u.last_active
        ORDER BY u.last_active DESC
    `, (err, results) => {
        if (err) {
            console.error('Admin users query error:', err);
            return res.status(500).json({ error: 'Admin users query failed' });
        }
        res.json(results || []);
    });
});

// ============================================================
//  ADMIN USER PROFILE
// ============================================================

app.get('/api/admin/user/:id', (req, res) => {
    const userId = req.params.id;
    
    db.query("SELECT user_id, username, email, balance, created_at, last_active FROM users WHERE user_id = ?", [userId], (err, results) => {
        if (err) return res.status(500).json({ error: 'User query failed' });
        if (results.length === 0) return res.status(404).json({ error: 'User not found' });
        
        const user = results[0];
        
        const portfolioQuery = `
            SELECT 
                p.stock_id, s.symbol, s.company_name, p.quantity, p.avg_buy_price, s.current_price,
                (p.quantity * s.current_price) AS current_value,
                ((p.quantity * s.current_price) - (p.quantity * p.avg_buy_price)) AS profit_loss
            FROM portfolio p
            JOIN stocks s ON p.stock_id = s.stock_id
            WHERE p.user_id = ?
        `;
        
        db.query(portfolioQuery, [userId], (err, portfolio) => {
            if (err) return res.status(500).json({ error: 'Portfolio query failed' });
            
            db.query(`
                SELECT * FROM transactions WHERE user_id = ?
                ORDER BY transaction_date DESC LIMIT 10
            `, [userId], (err, transactions) => {
                if (err) return res.status(500).json({ error: 'Transactions query failed' });
                
                res.json({
                    user: user,
                    portfolio: portfolio || [],
                    recent_transactions: transactions || []
                });
            });
        });
    });
});

// ============================================================
//  BUY / SELL
// ============================================================

app.post('/api/buy', (req, res) => {
    const { user_id, stock_id, quantity } = req.body;
    if (!user_id || !stock_id || !quantity || quantity <= 0) {
        return res.status(400).json({ error: 'Invalid input' });
    }

    db.query("SELECT * FROM stocks WHERE stock_id = ?", [stock_id], (err, stockResult) => {
        if (err || stockResult.length === 0) {
            return res.status(400).json({ error: 'Stock not found' });
        }

        const price = stockResult[0].current_price;
        const total = price * quantity;

        db.query("SELECT balance FROM users WHERE user_id = ?", [user_id], (err, userResult) => {
            if (err) return res.status(500).json({ error: 'User query failed' });
            if (!userResult[0] || userResult[0].balance < total) {
                return res.status(400).json({ error: 'Insufficient balance' });
            }

            db.beginTransaction(err => {
                if (err) return res.status(500).json({ error: 'Transaction failed' });

                db.query(
                    "INSERT INTO orders (user_id, stock_id, order_type, quantity, price, status) VALUES (?, ?, 'BUY', ?, ?, 'PENDING')",
                    [user_id, stock_id, quantity, price],
                    (err, orderResult) => {
                        if (err) return db.rollback(() => res.status(500).json({ error: 'Order failed' }));

                        const orderId = orderResult.insertId;
                        db.query(
                            "INSERT INTO transactions (order_id, user_id, stock_id, quantity, price_per_share, total_amount) VALUES (?, ?, ?, ?, ?, ?)",
                            [orderId, user_id, stock_id, quantity, price, total],
                            (err) => {
                                if (err) return db.rollback(() => res.status(500).json({ error: 'Transaction insert failed' }));

                                db.commit(err => {
                                    if (err) return db.rollback(() => res.status(500).json({ error: 'Commit failed' }));
                                    res.json({
                                        success: true,
                                        message: `Bought ${quantity} shares of ${stockResult[0].symbol}`,
                                        total: total,
                                        order_id: orderId
                                    });
                                });
                            }
                        );
                    }
                );
            });
        });
    });
});

app.post('/api/sell', (req, res) => {
    const { user_id, stock_id, quantity } = req.body;
    if (!user_id || !stock_id || !quantity || quantity <= 0) {
        return res.status(400).json({ error: 'Invalid input' });
    }

    db.query("SELECT * FROM portfolio WHERE user_id = ? AND stock_id = ?", [user_id, stock_id], (err, pfResult) => {
        if (err) return res.status(500).json({ error: 'Portfolio query failed' });
        if (!pfResult[0] || pfResult[0].quantity < quantity) {
            return res.status(400).json({ error: 'Not enough shares' });
        }

        db.query("SELECT * FROM stocks WHERE stock_id = ?", [stock_id], (err, stockResult) => {
            if (err) return res.status(500).json({ error: 'Stock query failed' });
            const price = stockResult[0].current_price;
            const total = price * quantity;

            db.beginTransaction(err => {
                if (err) return res.status(500).json({ error: 'Transaction failed' });

                db.query(
                    "INSERT INTO orders (user_id, stock_id, order_type, quantity, price, status) VALUES (?, ?, 'SELL', ?, ?, 'PENDING')",
                    [user_id, stock_id, quantity, price],
                    (err, orderResult) => {
                        if (err) return db.rollback(() => res.status(500).json({ error: 'Order failed' }));

                        db.query(
                            "INSERT INTO transactions (order_id, user_id, stock_id, quantity, price_per_share, total_amount) VALUES (?, ?, ?, ?, ?, ?)",
                            [orderResult.insertId, user_id, stock_id, quantity, price, total],
                            (err) => {
                                if (err) return db.rollback(() => res.status(500).json({ error: 'Transaction insert failed' }));

                                db.commit(err => {
                                    if (err) return db.rollback(() => res.status(500).json({ error: 'Commit failed' }));
                                    res.json({
                                        success: true,
                                        message: `Sold ${quantity} shares of ${stockResult[0].symbol}`,
                                        total: total
                                    });
                                });
                            }
                        );
                    }
                );
            });
        });
    });
});

// ============================================================
//  WATCHLIST OPERATIONS
// ============================================================

app.post('/api/watchlist', (req, res) => {
    const { user_id, stock_id } = req.body;
    db.query("INSERT IGNORE INTO watchlist (user_id, stock_id) VALUES (?, ?)", [user_id, stock_id], (err) => {
        if (err) return res.status(500).json({ error: 'Insert failed' });
        res.json({ success: true });
    });
});

app.delete('/api/watchlist/:id', (req, res) => {
    db.query("DELETE FROM watchlist WHERE watchlist_id = ?", [req.params.id], (err) => {
        if (err) return res.status(500).json({ error: 'Delete failed' });
        res.json({ success: true });
    });
});

// ============================================================
//  START SERVER
// ============================================================

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`🚀 API running on http://localhost:${PORT}`);
});
