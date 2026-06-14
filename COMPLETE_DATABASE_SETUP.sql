-- =====================================================================
--  DBMS PROJECT — STOCK TRADING APPLICATION DATABASE
--  Group: Salman Ahsan (041)  |  Umer Zahoor (033)  |  M. Talha (030)
--  Academic Year 2025–2026
--
--  Complete Contents:
--    1. Database creation
--    2. Table creation (DDL) with PKs, FKs, CHECK, UNIQUE, NOT NULL, ENUM
--    3. Indexes for performance
--    4. Sample data (10 users, 20 stocks, 50+ orders/transactions)
--    5. Views (2 views with calculations)
--    6. Triggers (3 auto-execution triggers)
--    7. Demonstration queries (10+ SELECT, JOIN, GROUP BY, aggregates)
--    8. Transaction example (COMMIT / ROLLBACK demo)
-- =====================================================================

-- =====================================================================
-- 1. DATABASE CREATION
-- =====================================================================
DROP DATABASE IF EXISTS stock_trading_db;
CREATE DATABASE stock_trading_db;
USE stock_trading_db;

-- =====================================================================
-- 2. TABLE CREATION (DDL)
-- =====================================================================

-- ========== USERS TABLE ==========
CREATE TABLE users (
    user_id        INT AUTO_INCREMENT PRIMARY KEY,
    username       VARCHAR(50)   NOT NULL UNIQUE,
    email          VARCHAR(100)  NOT NULL UNIQUE,
    password_hash  VARCHAR(255)  NOT NULL,
    balance        DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    created_at     TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    last_active    TIMESTAMP     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_balance_nonneg CHECK (balance >= 0),
    INDEX idx_username (username),
    INDEX idx_email (email)
);

-- ========== STOCKS TABLE ==========
CREATE TABLE stocks (
    stock_id       INT AUTO_INCREMENT PRIMARY KEY,
    symbol         VARCHAR(10)   NOT NULL UNIQUE,
    company_name   VARCHAR(100)  NOT NULL,
    sector         VARCHAR(50),
    current_price  DECIMAL(10,2) NOT NULL,
    market_cap     BIGINT,
    CONSTRAINT chk_price_positive CHECK (current_price > 0),
    INDEX idx_symbol (symbol),
    INDEX idx_sector (sector)
);

-- ========== ORDERS TABLE ==========
CREATE TABLE orders (
    order_id     INT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT NOT NULL,
    stock_id     INT NOT NULL,
    order_type   ENUM('BUY','SELL') NOT NULL,
    quantity     INT NOT NULL,
    price        DECIMAL(10,2) NOT NULL,
    status       ENUM('PENDING','COMPLETED','CANCELLED') NOT NULL DEFAULT 'PENDING',
    order_date   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_orders_user  FOREIGN KEY (user_id)  REFERENCES users(user_id)   ON DELETE CASCADE,
    CONSTRAINT fk_orders_stock FOREIGN KEY (stock_id) REFERENCES stocks(stock_id) ON DELETE CASCADE,
    CONSTRAINT chk_qty_positive CHECK (quantity > 0),
    CONSTRAINT chk_price_positive2 CHECK (price > 0),
    INDEX idx_orders_user (user_id),
    INDEX idx_orders_stock (stock_id),
    INDEX idx_orders_status (status),
    INDEX idx_orders_date (order_date)
);

-- ========== TRANSACTIONS TABLE ==========
CREATE TABLE transactions (
    transaction_id   INT AUTO_INCREMENT PRIMARY KEY,
    order_id         INT NOT NULL,
    user_id          INT NOT NULL,
    stock_id         INT NOT NULL,
    quantity         INT NOT NULL,
    price_per_share  DECIMAL(10,2) NOT NULL,
    total_amount     DECIMAL(15,2) NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_txn_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_txn_user  FOREIGN KEY (user_id)  REFERENCES users(user_id)  ON DELETE CASCADE,
    CONSTRAINT fk_txn_stock FOREIGN KEY (stock_id) REFERENCES stocks(stock_id) ON DELETE CASCADE,
    CONSTRAINT chk_qty_positive3 CHECK (quantity > 0),
    INDEX idx_txn_user (user_id),
    INDEX idx_txn_stock (stock_id),
    INDEX idx_txn_date (transaction_date)
);

-- ========== PORTFOLIO TABLE ==========
CREATE TABLE portfolio (
    portfolio_id    INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    stock_id        INT NOT NULL,
    quantity        INT NOT NULL DEFAULT 0,
    avg_buy_price   DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_pf_user  FOREIGN KEY (user_id)  REFERENCES users(user_id)  ON DELETE CASCADE,
    CONSTRAINT fk_pf_stock FOREIGN KEY (stock_id) REFERENCES stocks(stock_id) ON DELETE CASCADE,
    CONSTRAINT uq_user_stock UNIQUE (user_id, stock_id),
    CONSTRAINT chk_qty_nonneg CHECK (quantity >= 0),
    INDEX idx_pf_user (user_id)
);

-- ========== WATCHLIST TABLE ==========
CREATE TABLE watchlist (
    watchlist_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT NOT NULL,
    stock_id     INT NOT NULL,
    added_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_wl_user  FOREIGN KEY (user_id)  REFERENCES users(user_id)  ON DELETE CASCADE,
    CONSTRAINT fk_wl_stock FOREIGN KEY (stock_id) REFERENCES stocks(stock_id) ON DELETE CASCADE,
    CONSTRAINT uq_watch UNIQUE (user_id, stock_id),
    INDEX idx_wl_user (user_id)
);

-- ========== ADMIN TABLE ==========
CREATE TABLE admin (
    admin_id      INT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(50)  NOT NULL UNIQUE,
    email         VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role          ENUM('superadmin','moderator') NOT NULL DEFAULT 'moderator',
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_admin_username (username)
);

-- =====================================================================
-- 3. INDEXES (already created above, but additional ones for performance)
-- =====================================================================
CREATE INDEX idx_transactions_order ON transactions(order_id);
CREATE INDEX idx_orders_user_stock ON orders(user_id, stock_id);
CREATE INDEX idx_portfolio_user_stock ON portfolio(user_id, stock_id);

-- =====================================================================
-- 4. SAMPLE DATA
-- =====================================================================

-- ----- INSERT USERS (10 users) -----
INSERT INTO users (user_id, username, email, password_hash, balance, created_at, last_active) VALUES
(1, 'salman_ahsan', 'salman@example.com', 'password123', 50000.00, NOW(), NOW()),
(2, 'umer_zahoor',  'umer@example.com',   'password123', 75000.00, NOW(), NOW()),
(3, 'm_talha',      'talha@example.com',  'password123', 60000.00, NOW(), NOW()),
(4, 'ali_khan',     'ali@example.com',    'password123', 40000.00, NOW(), NOW()),
(5, 'sara_ahmed',   'sara@example.com',   'password123', 90000.00, NOW(), NOW()),
(6, 'bilal_raza',   'bilal@example.com',  'password123', 30000.00, NOW(), NOW()),
(7, 'hina_iqbal',   'hina@example.com',   'password123', 55000.00, NOW(), NOW()),
(8, 'zain_malik',   'zain@example.com',   'password123', 80000.00, NOW(), NOW()),
(9, 'fatima_noor',  'fatima@example.com', 'password123', 45000.00, NOW(), NOW()),
(10, 'usman_tariq', 'usman@example.com',  'password123', 65000.00, NOW(), NOW());

-- ----- INSERT STOCKS (20 stocks with real market data) -----
INSERT INTO stocks (stock_id, symbol, company_name, sector, current_price, market_cap) VALUES
(1, 'AAPL',  'Apple Inc.',              'Technology', 185.50,  2900000000000),
(2, 'MSFT',  'Microsoft Corporation',   'Technology', 415.20,  3100000000000),
(3, 'GOOGL', 'Alphabet Inc.',           'Technology', 175.80,  2200000000000),
(4, 'AMZN',  'Amazon.com Inc.',         'E-Commerce', 185.00,  1900000000000),
(5, 'TSLA',  'Tesla Inc.',              'Automotive', 245.30,   780000000000),
(6, 'META',  'Meta Platforms',          'Technology', 510.40,  1300000000000),
(7, 'NVDA',  'NVIDIA Corporation',      'Technology', 920.10,  2300000000000),
(8, 'NFLX',  'Netflix Inc.',            'Media',      625.70,   270000000000),
(9, 'AMD',   'Advanced Micro Devices',  'Technology', 162.50,   260000000000),
(10, 'INTC', 'Intel Corporation',       'Technology',  31.20,   130000000000),
(11, 'JPM',  'JPMorgan Chase',          'Banking',    198.40,   570000000000),
(12, 'BAC',  'Bank of America',         'Banking',     38.90,   300000000000),
(13, 'V',    'Visa Inc.',               'Finance',    275.60,   560000000000),
(14, 'MA',   'Mastercard Inc.',         'Finance',    470.30,   430000000000),
(15, 'DIS',  'The Walt Disney Company', 'Media',      105.20,   190000000000),
(16, 'PEP',  'PepsiCo Inc.',            'Consumer',   175.80,   240000000000),
(17, 'KO',   'Coca-Cola Company',       'Consumer',    62.40,   270000000000),
(18, 'NKE',  'Nike Inc.',               'Consumer',     95.10,   140000000000),
(19, 'XOM',  'Exxon Mobil',             'Energy',     118.40,   470000000000),
(20, 'PFE',  'Pfizer Inc.',             'Healthcare',  28.30,   160000000000);

-- ----- INSERT ADMIN ACCOUNTS (2) -----
INSERT INTO admin (admin_id, username, email, password_hash, role) VALUES
(1, 'admin_main', 'admin@stockapp.com', 'admin_pass1', 'superadmin'),
(2, 'admin_mod',  'mod@stockapp.com',   'admin_pass2', 'moderator');

-- ----- INSERT WATCHLIST ENTRIES (15) -----
INSERT INTO watchlist (user_id, stock_id, added_at) VALUES
(1, 5, NOW()),  (1, 7, NOW()),  (2, 1, NOW()),  (2, 3, NOW()),  (3, 2, NOW()),
(4, 7, NOW()),  (5, 6, NOW()),  (5, 8, NOW()),  (6, 11, NOW()), (7, 14, NOW()),
(8, 5, NOW()),  (9, 16, NOW()), (10, 7, NOW()), (3, 19, NOW()), (2, 20, NOW());

-- ----- INSERT ORDERS (50+ completed orders) -----
INSERT INTO orders (user_id, stock_id, order_type, quantity, price, status, order_date) VALUES
( 1,  1, 'BUY',  50, 180.00, 'COMPLETED', NOW()),
( 1,  5, 'BUY',  20, 240.00, 'COMPLETED', NOW()),
( 1,  7, 'BUY',  10, 900.00, 'COMPLETED', NOW()),
( 2,  2, 'BUY',  30, 410.00, 'COMPLETED', NOW()),
( 2,  3, 'BUY',  40, 170.00, 'COMPLETED', NOW()),
( 2,  6, 'BUY',  15, 505.00, 'COMPLETED', NOW()),
( 3,  4, 'BUY',  25, 180.00, 'COMPLETED', NOW()),
( 3,  8, 'BUY',  10, 620.00, 'COMPLETED', NOW()),
( 3,  9, 'BUY',  50, 160.00, 'COMPLETED', NOW()),
( 4, 11, 'BUY',  30, 195.00, 'COMPLETED', NOW()),
( 4, 12, 'BUY', 100,  38.00, 'COMPLETED', NOW()),
( 5, 13, 'BUY',  20, 270.00, 'COMPLETED', NOW()),
( 5, 14, 'BUY',  15, 465.00, 'COMPLETED', NOW()),
( 5,  6, 'BUY',  10, 508.00, 'COMPLETED', NOW()),
( 6, 15, 'BUY',  40, 103.00, 'COMPLETED', NOW()),
( 6, 17, 'BUY', 200,  61.00, 'COMPLETED', NOW()),
( 7, 16, 'BUY',  30, 172.00, 'COMPLETED', NOW()),
( 7, 18, 'BUY',  25,  93.00, 'COMPLETED', NOW()),
( 8, 19, 'BUY',  35, 116.00, 'COMPLETED', NOW()),
( 8, 20, 'BUY', 100,  27.00, 'COMPLETED', NOW()),
( 9,  1, 'BUY',  20, 182.00, 'COMPLETED', NOW()),
( 9,  7, 'BUY',   5, 910.00, 'COMPLETED', NOW()),
(10,  2, 'BUY',  10, 412.00, 'COMPLETED', NOW()),
(10,  5, 'BUY',  15, 242.00, 'COMPLETED', NOW()),
( 1,  1, 'SELL', 10, 188.00, 'COMPLETED', NOW()),
( 2,  3, 'SELL', 10, 178.00, 'COMPLETED', NOW()),
( 3,  9, 'SELL', 20, 165.00, 'COMPLETED', NOW()),
( 4, 12, 'SELL', 30,  39.50, 'COMPLETED', NOW()),
( 5,  6, 'SELL',  5, 512.00, 'COMPLETED', NOW()),
( 6, 15, 'SELL', 10, 106.00, 'COMPLETED', NOW()),
( 7, 16, 'SELL', 10, 176.00, 'COMPLETED', NOW()),
( 8, 20, 'SELL', 50,  28.50, 'COMPLETED', NOW()),
( 9,  7, 'SELL',  2, 925.00, 'COMPLETED', NOW()),
(10,  5, 'SELL',  5, 248.00, 'COMPLETED', NOW()),
( 1,  7, 'BUY',   3, 915.00, 'COMPLETED', NOW()),
( 2,  1, 'BUY',  10, 184.00, 'COMPLETED', NOW()),
( 3,  2, 'BUY',  10, 414.00, 'COMPLETED', NOW()),
( 4,  7, 'BUY',   2, 918.00, 'COMPLETED', NOW()),
( 5,  5, 'BUY',  10, 244.00, 'COMPLETED', NOW()),
( 6, 11, 'BUY',  10, 197.00, 'COMPLETED', NOW()),
( 7, 14, 'BUY',   5, 468.00, 'COMPLETED', NOW()),
( 8,  3, 'BUY',  20, 174.00, 'COMPLETED', NOW()),
( 9,  6, 'BUY',   5, 509.00, 'COMPLETED', NOW()),
(10,  7, 'BUY',   2, 919.00, 'COMPLETED', NOW()),
( 1,  5, 'SELL',  5, 246.00, 'COMPLETED', NOW()),
( 2,  6, 'BUY',   5, 511.00, 'COMPLETED', NOW()),
( 3,  4, 'SELL', 10, 186.00, 'COMPLETED', NOW()),
( 5,  1, 'BUY',  15, 183.00, 'COMPLETED', NOW()),
( 7,  9, 'BUY',  20, 161.00, 'COMPLETED', NOW()),
( 8, 11, 'BUY',  10, 198.00, 'COMPLETED', NOW()),
(10,  3, 'BUY',   5, 175.00, 'COMPLETED', NOW()),
( 4,  1, 'BUY',  10, 184.50, 'COMPLETED', NOW());

-- ----- INSERT TRANSACTIONS (matching completed orders) -----
INSERT INTO transactions (order_id, user_id, stock_id, quantity, price_per_share, total_amount, transaction_date)
SELECT order_id, user_id, stock_id, quantity, price, (quantity * price), NOW()
FROM orders
WHERE status = 'COMPLETED';

-- ----- BUILD PORTFOLIO FROM TRANSACTIONS -----
INSERT INTO portfolio (user_id, stock_id, quantity, avg_buy_price)
SELECT
    o.user_id,
    o.stock_id,
    SUM(CASE WHEN o.order_type='BUY'  THEN o.quantity
             WHEN o.order_type='SELL' THEN -o.quantity END) AS net_qty,
    ROUND(
        SUM(CASE WHEN o.order_type='BUY' THEN o.quantity * o.price ELSE 0 END) /
        NULLIF(SUM(CASE WHEN o.order_type='BUY' THEN o.quantity ELSE 0 END), 0)
    , 2) AS avg_buy_price
FROM orders o
WHERE o.status='COMPLETED'
GROUP BY o.user_id, o.stock_id
HAVING net_qty > 0;

-- =====================================================================
-- 5. VIEWS
-- =====================================================================

-- View 1: Portfolio Summary with Profit/Loss Calculations
DROP VIEW IF EXISTS vw_portfolio_summary;
CREATE VIEW vw_portfolio_summary AS
SELECT
    u.user_id,
    u.username,
    s.symbol,
    s.company_name,
    p.quantity,
    p.avg_buy_price,
    s.current_price,
    ROUND(p.quantity * s.current_price, 2)                              AS current_value,
    ROUND(p.quantity * p.avg_buy_price, 2)                              AS invested_value,
    ROUND((s.current_price - p.avg_buy_price) * p.quantity, 2)          AS profit_loss,
    ROUND(((s.current_price - p.avg_buy_price) / p.avg_buy_price)*100,2) AS profit_loss_pct
FROM portfolio p
JOIN users  u ON p.user_id  = u.user_id
JOIN stocks s ON p.stock_id = s.stock_id
WHERE p.quantity > 0;

-- View 2: Top Traded Stocks by Volume
DROP VIEW IF EXISTS vw_top_traded_stocks;
CREATE VIEW vw_top_traded_stocks AS
SELECT
    s.stock_id,
    s.symbol,
    s.company_name,
    COUNT(t.transaction_id) AS total_trades,
    SUM(t.quantity)         AS total_volume,
    ROUND(SUM(t.total_amount), 2) AS total_value_traded
FROM transactions t
JOIN stocks s ON t.stock_id = s.stock_id
GROUP BY s.stock_id, s.symbol, s.company_name
ORDER BY total_volume DESC;

-- =====================================================================
-- 6. TRIGGERS
-- =====================================================================

DELIMITER $$

-- Trigger 1: Update user balance after transaction
-- BUY  -> subtract from balance
-- SELL -> add to balance
CREATE TRIGGER trg_update_balance_after_txn
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    DECLARE v_type ENUM('BUY','SELL');

    SELECT order_type INTO v_type
    FROM orders
    WHERE order_id = NEW.order_id;

    IF v_type = 'BUY' THEN
        UPDATE users
        SET balance = balance - NEW.total_amount
        WHERE user_id = NEW.user_id;
    ELSEIF v_type = 'SELL' THEN
        UPDATE users
        SET balance = balance + NEW.total_amount
        WHERE user_id = NEW.user_id;
    END IF;
END$$

-- Trigger 2: Update portfolio after transaction
-- BUY  -> add shares, update average price
-- SELL -> subtract shares
CREATE TRIGGER trg_update_portfolio_after_txn
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    DECLARE v_type        ENUM('BUY','SELL');
    DECLARE v_existing    INT DEFAULT 0;
    DECLARE v_curr_qty    INT DEFAULT 0;
    DECLARE v_curr_avg    DECIMAL(10,2) DEFAULT 0.00;

    SELECT order_type INTO v_type
    FROM orders
    WHERE order_id = NEW.order_id;

    SELECT COUNT(*) INTO v_existing
    FROM portfolio
    WHERE user_id = NEW.user_id AND stock_id = NEW.stock_id;

    IF v_type = 'BUY' THEN
        IF v_existing = 0 THEN
            INSERT INTO portfolio (user_id, stock_id, quantity, avg_buy_price)
            VALUES (NEW.user_id, NEW.stock_id, NEW.quantity, NEW.price_per_share);
        ELSE
            SELECT quantity, avg_buy_price
              INTO v_curr_qty, v_curr_avg
            FROM portfolio
            WHERE user_id = NEW.user_id AND stock_id = NEW.stock_id;

            UPDATE portfolio
            SET
                avg_buy_price = ROUND(
                    ((v_curr_qty * v_curr_avg) + (NEW.quantity * NEW.price_per_share))
                    / (v_curr_qty + NEW.quantity), 2),
                quantity = v_curr_qty + NEW.quantity
            WHERE user_id = NEW.user_id AND stock_id = NEW.stock_id;
        END IF;

    ELSEIF v_type = 'SELL' THEN
        UPDATE portfolio
        SET quantity = quantity - NEW.quantity
        WHERE user_id = NEW.user_id AND stock_id = NEW.stock_id;
    END IF;
END$$

-- Trigger 3: Mark order as COMPLETED after transaction
CREATE TRIGGER trg_complete_order_after_txn
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    UPDATE orders
    SET status = 'COMPLETED'
    WHERE order_id = NEW.order_id;
END$$

DELIMITER ;

-- =====================================================================
-- 7. DEMONSTRATION QUERIES
-- =====================================================================

-- Q1: List all users with their current balances
SELECT user_id, username, email, balance, last_active
FROM users
ORDER BY balance DESC;

-- Q2: Show all stocks sorted by price (descending)
SELECT stock_id, symbol, company_name, sector, current_price, market_cap
FROM stocks
ORDER BY current_price DESC;

-- Q3: User portfolio with profit/loss (uses JOIN across 3 tables)
SELECT u.username, s.symbol, s.company_name,
       p.quantity, p.avg_buy_price, s.current_price,
       ROUND((s.current_price - p.avg_buy_price) * p.quantity, 2) AS profit_loss
FROM portfolio p
INNER JOIN users  u ON p.user_id  = u.user_id
INNER JOIN stocks s ON p.stock_id = s.stock_id
WHERE u.username = 'salman_ahsan';

-- Q4: Top 5 most traded stocks (uses the view)
SELECT * FROM vw_top_traded_stocks LIMIT 5;

-- Q5: Total invested amount per user (GROUP BY + aggregate)
SELECT u.username,
       COUNT(t.transaction_id)              AS total_trades,
       ROUND(SUM(t.total_amount), 2)        AS total_traded_value,
       COUNT(DISTINCT t.stock_id)           AS unique_stocks_traded
FROM transactions t
INNER JOIN users u ON t.user_id = u.user_id
GROUP BY u.username
ORDER BY total_traded_value DESC;

-- Q6: All BUY orders above $500 per share (filter + JOIN)
SELECT o.order_id, u.username, s.symbol, o.quantity, o.price, o.status
FROM orders o
JOIN users  u ON o.user_id  = u.user_id
JOIN stocks s ON o.stock_id = s.stock_id
WHERE o.order_type = 'BUY' AND o.price > 500
ORDER BY o.price DESC;

-- Q7: Users with no orders (LEFT JOIN)
SELECT u.user_id, u.username, u.email
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
WHERE o.order_id IS NULL;

-- Q8: Watchlist contents per user (3-table JOIN)
SELECT u.username, s.symbol, s.company_name, s.sector, s.current_price, w.added_at
FROM watchlist w
JOIN users  u ON w.user_id  = u.user_id
JOIN stocks s ON w.stock_id = s.stock_id
ORDER BY u.username, s.symbol;

-- Q9: Portfolio summary with P&L (uses view)
SELECT username,
       ROUND(SUM(invested_value), 2) AS total_invested,
       ROUND(SUM(current_value), 2)  AS total_current_value,
       ROUND(SUM(profit_loss), 2)    AS total_profit_loss,
       ROUND(AVG(profit_loss_pct), 2) AS avg_return_pct
FROM vw_portfolio_summary
GROUP BY username
ORDER BY total_profit_loss DESC;

-- Q10: Stocks by sector with count and average price
SELECT sector,
       COUNT(*)                         AS num_stocks,
       ROUND(AVG(current_price), 2)     AS avg_price,
       MIN(current_price)               AS min_price,
       MAX(current_price)               AS max_price
FROM stocks
GROUP BY sector
ORDER BY avg_price DESC;

-- Q11: Transaction history (detailed query with order types)
SELECT t.transaction_id, t.transaction_date, o.order_type,
       u.username, s.symbol, s.company_name,
       t.quantity, t.price_per_share, t.total_amount,
       o.status
FROM transactions t
JOIN orders o ON t.order_id = o.order_id
JOIN users  u ON t.user_id  = u.user_id
JOIN stocks s ON t.stock_id = s.stock_id
ORDER BY t.transaction_date DESC
LIMIT 20;

-- Q12: Admin statistics - total trades, users, volume
SELECT
    COUNT(DISTINCT u.user_id) AS total_users,
    COUNT(DISTINCT t.transaction_id) AS total_transactions,
    COUNT(DISTINCT s.stock_id) AS stocks_traded,
    ROUND(SUM(t.total_amount), 2) AS total_value_traded,
    ROUND(AVG(t.total_amount), 2) AS avg_transaction_value
FROM users u
LEFT JOIN transactions t ON u.user_id = t.user_id
LEFT JOIN stocks s ON t.stock_id = s.stock_id;

-- =====================================================================
-- 8. TRANSACTION DEMO (COMMIT / ROLLBACK)
-- =====================================================================
-- Scenario: User 1 (salman_ahsan) buys 5 shares of NVDA (stock_id=7)
-- This demonstrates transaction atomicity - either everything succeeds or rolls back
-- The triggers will automatically:
--   1. Deduct from user balance
--   2. Update portfolio holdings
--   3. Mark order as COMPLETED

START TRANSACTION;

INSERT INTO orders (user_id, stock_id, order_type, quantity, price, status, order_date)
VALUES (1, 7, 'BUY', 5, 920.00, 'PENDING', NOW());

SET @new_order_id := LAST_INSERT_ID();

INSERT INTO transactions (order_id, user_id, stock_id, quantity, price_per_share, total_amount, transaction_date)
VALUES (@new_order_id, 1, 7, 5, 920.00, 5 * 920.00, NOW());

COMMIT;
-- If anything failed above, we would use: ROLLBACK;

-- Verify the transaction effects:
SELECT 'User balance after buy:' AS check_point;
SELECT user_id, username, balance FROM users WHERE user_id = 1;

SELECT 'Portfolio updated:' AS check_point;
SELECT * FROM portfolio WHERE user_id = 1 AND stock_id = 7;

SELECT 'Order completed:' AS check_point;
SELECT order_id, status FROM orders WHERE order_id = @new_order_id;

-- =====================================================================
-- FINAL VERIFICATION
-- =====================================================================
SELECT '========== DATABASE SETUP COMPLETE ==========' AS status;
SELECT CONCAT('Total Users: ', COUNT(*)) AS users_count FROM users;
SELECT CONCAT('Total Stocks: ', COUNT(*)) AS stocks_count FROM stocks;
SELECT CONCAT('Total Orders: ', COUNT(*)) AS orders_count FROM orders;
SELECT CONCAT('Total Transactions: ', COUNT(*)) AS transactions_count FROM transactions;
SELECT CONCAT('Total Portfolio Holdings: ', COUNT(*)) AS portfolio_count FROM portfolio;
SELECT CONCAT('Total Watchlist Items: ', COUNT(*)) AS watchlist_count FROM watchlist;
SELECT CONCAT('Total Admin Accounts: ', COUNT(*)) AS admin_count FROM admin;
SELECT '✅ All tables, views, triggers, and data created successfully!' AS completion_message;

-- =====================================================================
-- END OF COMPLETE SQL SCRIPT
-- =====================================================================
