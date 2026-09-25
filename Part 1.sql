-- PART A: DATA CLEANING & PREPARATION
-- TradeZone E-Commerce Platform


-- SECTION 1: STANDARDISE CITY NAMES
-- INITCAP converts to Title Case, TRIM removes extra spaces
UPDATE customers
SET city = INITCAP(TRIM(city));

UPDATE sellers
SET city = INITCAP(TRIM(city));

-- Fix Port Harcourt variations 
UPDATE customers
SET city = 'Port Harcourt'
WHERE LOWER(TRIM(city)) IN ('port-harcourt', 'portharcourt');

UPDATE sellers
SET city = 'Port Harcourt'
WHERE LOWER(TRIM(city)) IN ('port-harcourt', 'portharcourt');

-- SECTION 2: NORMALISE PRODUCT CATEGORY TO TITLE CASE
UPDATE products
SET category = INITCAP(TRIM(category));

UPDATE sellers
SET product_category = INITCAP(TRIM(product_category));

-- SECTION 3: STANDARDISE DATE COLUMNS TO YYYY-MM-DD
-- PostgreSQL stores dates as DATE type natively in YYYY-MM-DD format.
-- Casting ensures any text-stored dates are converted correctly.
UPDATE customers
SET signup_date = signup_date::date;

UPDATE orders
SET order_date = order_date::date,
    delivery_date = delivery_date::date;

-- SECTION 4: DUPLICATE RECORDS — CUSTOMERS, SELLERS, ORDERS
-- Customers: check duplicates by email
SELECT email, COUNT(*) AS count
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;

-- Remove duplicate customers, keeping the earliest signup
DELETE FROM customers
WHERE customer_id NOT IN (
    SELECT MIN(customer_id)
    FROM customers
    GROUP BY email
);

-- Sellers: check duplicates by email
SELECT email, COUNT(*) AS count
FROM sellers
GROUP BY email
HAVING COUNT(*) > 1;

-- Remove duplicate sellers, keeping the earliest record
DELETE FROM sellers
WHERE seller_id NOT IN (
    SELECT MIN(seller_id)
    FROM sellers
    GROUP BY email
);

-- Orders: check duplicates by customer_id, order_date, total_amount
SELECT customer_id, order_date, total_amount, COUNT(*) AS count
FROM orders
GROUP BY customer_id, order_date, total_amount
HAVING COUNT(*) > 1;

-- Remove duplicate orders, keeping the earliest order_id
DELETE FROM orders
WHERE order_id NOT IN (
    SELECT MIN(order_id)
    FROM orders
    GROUP BY customer_id, order_date, total_amount
);

-- SECTION 5: FLAG AND REMOVE INVALID REVIEW RATINGS (must be 1-5)
-- Rating of 0 found in REV00718 — deleting as it is invalid
DELETE FROM reviews
WHERE rating < 1 OR rating > 5;

-- SECTION 6: CHECK FOR NEGATIVE PRODUCT PRICES AND INVALID DISCOUNTS
SELECT product_id, product_name, unit_price 
FROM products 
WHERE unit_price < 0;

-- Check for discount percentages above 100%
SELECT product_id, product_name, discount_percentage
FROM products
WHERE discount_percentage > 100;

-- Flag records but do not delete — pricing errors need business confirmation
-- If these were deleted incorrectly, revenue totals in Q2 and Q7 would be understated.

-- SECTION 7: FLAG ORDER AMOUNT MISMATCHES GREATER THAN ₦10
SELECT 
    o.order_id,
    o.total_amount AS recorded_total,
    SUM(oi.line_total) AS calculated_total,
    ABS(o.total_amount - SUM(oi.line_total)) AS difference
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount
HAVING ABS(o.total_amount - SUM(oi.line_total)) > 10
ORDER BY difference DESC;

-- SECTION 8: CHECK NULL VALUES IN CRITICAL COLUMNS
SELECT * FROM customers 
WHERE first_name IS NULL OR last_name IS NULL 
   OR email IS NULL OR signup_date IS NULL;

SELECT * FROM orders 
WHERE customer_id IS NULL OR order_date IS NULL 
   OR total_amount IS NULL;

SELECT * FROM products 
WHERE product_name IS NULL OR unit_price IS NULL;